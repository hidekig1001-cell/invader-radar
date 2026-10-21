extends GutTest

const SessionSave = preload("res://game/session_save.gd")
const AppScript = preload("res://scenes/app.gd")


## CHECK: 1
func test_cr1116_1_cloud_config_path_and_content() -> void:
	var app = AppScript.new()
	assert_eq(app.cloud_config_path, "res://data/cloud_config.json")
	var data = SessionSave.read_dict(app.cloud_config_path)
	assert_eq(data, {"project_id": "", "web_api_key": ""})
	app.free()
