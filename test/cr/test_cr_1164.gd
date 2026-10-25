extends GutTest

## CHECK: 1
func test_boot_splash_config() -> void:
	var cf = ConfigFile.new()
	var err = cf.load("res://project.godot")
	assert_eq(err, OK)
	assert_eq(cf.get_value("application", "boot_splash/show_image"), false)
	assert_eq(cf.get_value("application", "boot_splash/bg_color"), Color(0.05, 0.1, 0.2, 1))
	assert_eq(cf.get_value("application", "run/main_scene"), "res://scenes/app.tscn")
