extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")


func _make_cs(state_data: Dictionary) -> Node:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1111_config.json"
	cs.state_path = "user://test_cr_1111_state.json"
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	SessionSave.write_json(cs.state_path, state_data)
	return cs


## CHECK: 1
func test_cr1111_1_signup_then_commit_flow() -> void:
	var cs = _make_cs({"rev": 4})
	var first = cs.begin_push({"level_index": 2, "score": 30, "hints": 1})
	assert_eq(first["url"], "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=K")
	assert_eq(cs.pending, "signup")
	var second = cs.next_after(200, '{"localId": "u1", "idToken": "t1", "refreshToken": "r1"}')
	assert_eq(second["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents:commit")
	assert_eq(cs.pending, "commit")
	var third = cs.next_after(200, "{}")
	assert_eq(third, {})
	assert_eq(cs.pending, "")


## CHECK: 2
func test_cr1111_2_commit_body_score() -> void:
	var cs = _make_cs({"rev": 4})
	cs.begin_push({"level_index": 2, "score": 30, "hints": 1})
	var second = cs.next_after(200, '{"localId": "u1", "idToken": "t1", "refreshToken": "r1"}')
	var body = JSON.parse_string(second["body"])
	assert_eq(body["writes"][0]["update"]["fields"]["score"], {"integerValue": "30"})


## CHECK: 3
func test_cr1111_3_commit_body_rev() -> void:
	var cs = _make_cs({"rev": 4})
	cs.begin_push({"level_index": 2, "score": 30, "hints": 1})
	var second = cs.next_after(200, '{"localId": "u1", "idToken": "t1", "refreshToken": "r1"}')
	var body = JSON.parse_string(second["body"])
	assert_eq(body["writes"][0]["update"]["fields"]["rev"], {"integerValue": "4"})


## CHECK: 4
func test_cr1111_4_existing_uid_and_error() -> void:
	var cs = _make_cs({"rev": 7, "uid": "u9", "id_token": "t9"})
	var first = cs.begin_push({"level_index": 0, "score": 5, "hints": 3})
	assert_eq(first["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents:commit")
	assert_eq(cs.pending, "commit")

	var cs2 = _make_cs({"rev": 1})
	cs2.begin_push({"level_index": 0, "score": 5, "hints": 3})
	var res = cs2.next_after(400, '{"error": {}}')
	assert_eq(res, {})
	assert_eq(cs2.pending, "")
