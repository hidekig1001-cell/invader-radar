extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const Payload = preload("res://game/cloud_payload.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")
const LocalScript = preload("res://game/progress_store.gd")


func _make_cs() -> Node:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1115_config.json"
	cs.state_path = "user://test_cr_1115_state.json"
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	return cs


## CHECK: 1
func test_cr1115_1_begin_pull() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.state_path, {"rev": 2, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})
	var first = cs.begin_pull()
	assert_eq(first["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents/players/u9")
	assert_eq(first["method"], HTTPClient.METHOD_GET)
	assert_eq(cs.pending, "get")

	var cs2 = _make_cs()
	SessionSave.write_json(cs2.state_path, {"rev": 2})
	var empty = cs2.begin_pull()
	assert_true(empty.is_empty())
	assert_eq(cs2.pending, "")


## CHECK: 2
func test_cr1115_2_apply_server_on_get_done() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.state_path, {"rev": 2, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})
	var local = LocalScript.new()
	local.path = "user://test_cr_1115_progress.json"
	local.clear()
	cs.local_store = local
	watch_signals(cs)

	cs.pending = "get"
	var body = JSON.stringify({"fields": Payload.build_fields({"level_index": 5, "score": 40, "hints": 2}, 9, "1.11")})
	var result = cs.next_after(200, body)
	assert_true(result.is_empty())
	assert_eq(int(SessionSave.read_dict(cs.state_path)["rev"]), 9)
	assert_eq(local.load_progress()["score"], 40)
	assert_eq(get_signal_emit_count(cs, "pulled"), 1)


## CHECK: 3
func test_cr1115_3_refresh_on_401_then_get() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.state_path, {"rev": 2, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})

	cs.pending = "get"
	var first = cs.next_after(401, "{}")
	assert_eq(first["url"], "https://securetoken.googleapis.com/v1/token?key=K")
	assert_eq(cs.pending, "refresh")
	assert_eq(cs.after_refresh, "get")

	var second = cs.next_after(200, '{"id_token": "t2", "refresh_token": "r2"}')
	assert_eq(second["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents/players/u9")
	assert_eq(second["headers"][0], "Authorization: Bearer t2")
	assert_eq(cs.pending, "get")


## CHECK: 4
func test_cr1115_4_server_is_newer_check() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.state_path, {"rev": 12, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})
	watch_signals(cs)

	cs.pending = "get"
	var body = JSON.stringify({"fields": Payload.build_fields({"level_index": 5, "score": 40, "hints": 2}, 9, "1.11")})
	var result = cs.next_after(200, body)
	assert_true(result.is_empty())
	assert_eq(int(SessionSave.read_dict(cs.state_path)["rev"]), 12)
	assert_eq(get_signal_emit_count(cs, "pulled"), 0)

	cs.pending = "get"
	var body15 = JSON.stringify({"fields": Payload.build_fields({"level_index": 6, "score": 50, "hints": 2}, 15, "1.11")})
	cs.next_after(200, body15)
	assert_eq(int(SessionSave.read_dict(cs.state_path)["rev"]), 15)
	assert_eq(get_signal_emit_count(cs, "pulled"), 1)
