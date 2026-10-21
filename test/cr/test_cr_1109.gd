extends GutTest

## CHECK: 1
func test_cr1109_1_signup_done() -> void:
	var Save = load("res://game/session_save.gd")
	var StoreScript = load("res://scenes/cloud_store.gd")
	var cs = autofree(StoreScript.new())
	cs.state_path = "user://test_cr_1109_state.json"
	Save.write_json(cs.state_path, {"rev": 2})

	assert_false(cs.on_signup_done(400, '{"error": {}}'))
	assert_false(cs.load_state().has("uid"))

	assert_false(cs.on_signup_done(200, "not json"))

	assert_true(cs.on_signup_done(200, '{"localId": "u1", "idToken": "t1", "refreshToken": "r1"}'))
	var st = cs.load_state()
	assert_eq(st["uid"], "u1")
	assert_eq(st["id_token"], "t1")
	assert_eq(st["refresh_token"], "r1")
	assert_eq(int(st["rev"]), 2)


## CHECK: 2
func test_cr1109_2_get_done() -> void:
	var StoreScript = load("res://scenes/cloud_store.gd")
	var cs = autofree(StoreScript.new())

	assert_eq(cs.on_get_done(404, ""), {})
	assert_eq(cs.on_get_done(200, "not json"), {})
	assert_eq(cs.on_get_done(200, '{"fields": {"rev": {"integerValue": "3"}, "score": {"integerValue": "40"}}}'), {"rev": 3, "score": 40})
