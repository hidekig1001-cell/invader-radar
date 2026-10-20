extends GutTest

## CHECK: 1
func test_icon_setting_and_texture() -> void:
	var icon_path = ProjectSettings.get_setting("application/config/icon", "")
	assert_eq(icon_path, "res://assets/title_logo/icon_play_512.png")
	var tex = load(icon_path) if icon_path != "" else null
	assert_not_null(tex)
	assert_true(tex is Texture2D)
	assert_eq(tex.get_size(), Vector2(512, 512))
