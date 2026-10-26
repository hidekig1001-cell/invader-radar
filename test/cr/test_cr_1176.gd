extends GutTest

## CHECK: 1
func test_vibrate_permission_is_true() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_eq(cf.get_value("preset.0.options", "permissions/vibrate"), true)
	assert_eq(cf.get_value("preset.0.options", "permissions/internet"), true)
