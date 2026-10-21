extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")


func _make_cs() -> Node:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1112_config.json"
	cs.state_path = "user://test_cr_1112_state.json"
	return cs


## CHECK: 1
func test_cr1112_1_on_request_completed_signup() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.config_path, {})
	SessionSave.write_json(cs.state_path, {"rev": 4})
	cs.pending = "signup"
	cs.on_request_completed(0, 200, PackedStringArray(), '{"localId": "u1", "idToken": "t1", "refreshToken": "r1"}'.to_utf8_buffer())
	var state = SessionSave.read_dict(cs.state_path)
	assert_eq(state["uid"], "u1")
	assert_eq(state["id_token"], "t1")
	assert_eq(cs.pending, "")


## CHECK: 2
func test_cr1112_2_push_unconfigured() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.config_path, {})
	SessionSave.write_json(cs.state_path, {"rev": 4})
	var err = cs.push({"level_index": 1, "score": 9, "hints": 2})
	assert_eq(err, ERR_UNCONFIGURED)
	assert_eq(cs.pending, "")
	assert_null(cs.http)


## CHECK: 3
func test_cr1112_3_http_connected() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	SessionSave.write_json(cs.state_path, {"rev": 4})
	cs.ensure_http()
	assert_true(cs.http.request_completed.is_connected(cs.on_request_completed))


## CHECK: 4
func test_cr1112_4_push_busy() -> void:
	var cs = _make_cs()
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	SessionSave.write_json(cs.state_path, {"rev": 4})
	cs.pending = "commit"
	var err = cs.push({"level_index": 1, "score": 9, "hints": 2})
	assert_eq(err, ERR_BUSY)
	assert_eq(cs.queued["score"], 9)
	assert_eq(cs.pending, "commit")
