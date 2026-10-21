extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")


func _setup_cs() -> Node:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1113_config.json"
	cs.state_path = "user://test_cr_1113_state.json"
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	SessionSave.write_json(cs.state_path, {"rev": 4, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})
	return cs


## CHECK: 1
func test_cr1113_1_refresh_on_401() -> void:
	var cs = _setup_cs()
	cs.pending = "commit"
	var first = cs.next_after(401, "{}")
	assert_eq(first["url"], "https://securetoken.googleapis.com/v1/token?key=K")
	assert_eq(first["body"], "grant_type=refresh_token&refresh_token=r9")
	assert_eq(cs.pending, "refresh")
	assert_true(cs.refreshed)


## CHECK: 2
func test_cr1113_2_refresh_success_then_commit() -> void:
	var cs = _setup_cs()
	cs.pending = "commit"
	var first = cs.next_after(401, "{}")
	assert_eq(first["url"], "https://securetoken.googleapis.com/v1/token?key=K")
	var second = cs.next_after(200, '{"id_token": "t2", "refresh_token": "r2", "user_id": "u9"}')
	assert_eq(second["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents:commit")
	assert_eq(second["headers"][1], "Authorization: Bearer t2")
	assert_eq(cs.pending, "commit")
	var state = SessionSave.read_dict(cs.state_path)
	assert_eq(state["refresh_token"], "r2")
	var third = cs.next_after(401, "{}")
	assert_true(third.is_empty())
	assert_eq(cs.pending, "")


## CHECK: 3
func test_cr1113_3_refresh_failure_and_retry() -> void:
	var cs = _setup_cs()
	cs.pending = "refresh"
	var res = cs.next_after(400, '{"error": {}}')
	assert_true(res.is_empty())
	assert_eq(cs.pending, "")
	var state = SessionSave.read_dict(cs.state_path)
	assert_eq(state["id_token"], "t9")
	cs.pending = "refresh"
	var third = cs.next_after(200, '{"id_token": "t3", "refresh_token": "r3"}')
	assert_eq(third["headers"][1], "Authorization: Bearer t3")
	assert_eq(cs.pending, "commit")


## CHECK: 4
func test_cr1113_4_begin_push_resets_refreshed() -> void:
	var cs = _setup_cs()
	cs.refreshed = true
	cs.begin_push({"level_index": 0, "score": 5, "hints": 3})
	assert_false(cs.refreshed)
	assert_eq(cs.pending, "commit")

