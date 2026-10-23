extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_title_button_text_localization() -> void:
	var m = await _start()
	assert_eq(m.hud.title_button.text, "BACK TO\nTITLE")
	m.hud.set_language("ja")
	assert_eq(m.hud.title_button.text, "タイトルに\n戻る")
	m.hud.set_language("en")
	assert_eq(m.hud.title_button.text, "BACK TO\nTITLE")


## CHECK: 2
func test_title_button_size_and_font_after_language_switch() -> void:
	var m = await _start()
	m.hud.set_language("ja")
	m.hud.set_language("en")
	assert_eq(m.hud.title_button.text, "BACK TO\nTITLE")
	assert_true(m.hud.title_button.get_combined_minimum_size().x <= 230.0)
	assert_eq(m.hud.title_button.get_theme_font_size("font_size"), 36)
