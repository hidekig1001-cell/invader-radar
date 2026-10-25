extends GutTest

## CHECK: 1
func test_architectures_x86_64_true() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_true(cf.get_value("preset.0.options", "architectures/x86_64"))

## CHECK: 1
func test_architectures_arm64_v8a_true() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_true(cf.get_value("preset.0.options", "architectures/arm64-v8a"))

## CHECK: 1
func test_architectures_armeabi_v7a_false() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_false(cf.get_value("preset.0.options", "architectures/armeabi-v7a"))

## CHECK: 1
func test_architectures_x86_false() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_false(cf.get_value("preset.0.options", "architectures/x86"))
