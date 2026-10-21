extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")


## CHECK: 1
func test_cr1108_1_no_config_returns_false() -> void:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1108_config.json"
	SessionSave.write_text(cs.config_path, "")
	assert_eq(cs.ensure_http(), false)
	assert_eq(cs.get_child_count(), 0)
	assert_null(cs.http)


## CHECK: 2
func test_cr1108_2_with_config_creates_http() -> void:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1108_config.json"
	SessionSave.write_json(cs.config_path, {"project_id": "p", "web_api_key": "k"})
	assert_eq(cs.ensure_http(), true)
	assert_eq(cs.get_child_count(), 1)
	assert_true(cs.get_child(0) == cs.http)
	assert_true(cs.http.has_signal("request_completed"))
	assert_eq(cs.ensure_http(), true)
	assert_eq(cs.get_child_count(), 1)
