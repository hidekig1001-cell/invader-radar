extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")
const LocalScript = preload("res://game/progress_store.gd")


## CHECK: 1
func test_cr1106_1_is_configured() -> void:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1106_config.json"

	SessionSave.write_text(cs.config_path, "")
	assert_false(cs.is_configured(), "Empty config should not be configured")

	SessionSave.write_json(cs.config_path, {"project_id": "p", "web_api_key": ""})
	assert_false(cs.is_configured(), "Missing web_api_key should not be configured")

	SessionSave.write_json(cs.config_path, {"project_id": "p", "web_api_key": "k"})
	assert_true(cs.is_configured(), "Valid config should be configured")


## CHECK: 2
func test_cr1106_2_save_progress_and_clear() -> void:
	var local = LocalScript.new()
	local.path = "user://test_cr_1106_progress.json"
	local.clear()

	var cs = autofree(StoreScript.new())
	cs.local_store = local
	cs.state_path = "user://test_cr_1106_state.json"

	SessionSave.write_text(cs.state_path, "")

	cs.save_progress({"level_index": 2, "score": 5, "hints": 1})
	assert_eq(cs.load_progress()["score"], 5)
	assert_eq(int(cs.load_state()["rev"]), 1)

	cs.save_progress({"level_index": 2, "score": 7, "hints": 1})
	assert_eq(int(cs.load_state()["rev"]), 2)

	cs.clear()
	assert_eq(cs.load_progress(), {})
	assert_eq(cs.get_child_count(), 0)
