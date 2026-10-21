extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")


## CHECK: 1
func test_cr1110_1_request_generation() -> void:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1110_config.json"
	cs.state_path = "user://test_cr_1110_state.json"
	SessionSave.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	SessionSave.write_json(cs.state_path, {"uid": "u1", "id_token": "t1"})

	var s = cs.signup_request()
	assert_eq(s["url"], "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=K")
	assert_eq(s["method"], 2)
	var s_body = JSON.parse_string(s["body"])
	assert_true(s_body is Dictionary)
	assert_eq(s_body.get("returnSecureToken"), true)

	var g = cs.get_request()
	assert_eq(g["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents/players/u1")
	assert_eq(g["method"], 0)
	assert_eq(g["headers"], ["Authorization: Bearer t1"])

	var c = cs.commit_request({"rev": {"integerValue": "3"}})
	assert_eq(c["url"], "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents:commit")
	assert_eq(c["method"], 2)
	assert_true(c["headers"].has("Authorization: Bearer t1"))
	var c_body = JSON.parse_string(c["body"])
	assert_true(c_body is Dictionary)
	assert_true(c_body.has("writes"))
	assert_true(c_body["writes"] is Array)
	assert_true(c_body["writes"].size() > 0)
	var update = c_body["writes"][0].get("update")
	assert_true(update is Dictionary)
	assert_eq(update.get("name"), "projects/p1/databases/(default)/documents/players/u1")


## CHECK: 2
func test_cr1110_2_send_unconfigured() -> void:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1110_config_empty.json"
	SessionSave.write_text(cs.config_path, "")

	var result = cs.send({"url": "https://example.invalid/", "headers": [], "method": 0, "body": ""})
	assert_eq(result, ERR_UNCONFIGURED)
	assert_eq(cs.get_child_count(), 0)
