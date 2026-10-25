extends GutTest

const Hud = preload("res://scenes/hud.gd")
const MainScene = preload("res://scenes/main.tscn")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1094_hud_settings_button_text() -> void:
	var hud = Hud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.set_language("ja")
	assert_eq(hud.settings_button.text, "説明")
	hud.set_language("en")
	assert_eq(hud.settings_button.text, "RULES")


## CHECK: 2
func test_cr_1094_main_open_rules_and_timer() -> void:
	var m = await _start_main()
	m.hud.settings_pressed.emit()
	assert_true(m.rules_panel.visible)
	assert_false(m.is_tutorial())
	assert_eq(m.rules_panel.body_label.text, m.rules_panel.rules_text(m.language))
	assert_eq(m.rules_panel.close_button.text, "CLOSE")
	var t0 = m.session.elapsed
	await wait_frames(5)
	assert_eq(m.session.elapsed, t0)
	m.rules_panel.close_button.pressed.emit()
	assert_false(m.rules_panel.visible)
	await wait_frames(5)
	assert_true(m.session.elapsed > t0)


## CHECK: 3
func test_cr_1094_main_ja_rules_and_layout() -> void:
	var m = MainScene.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	m.hud.settings_pressed.emit()
	assert_true(m.rules_panel.body_label.text.begins_with("ルール"))
	assert_eq(m.rules_panel.close_button.text, "閉じる")
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(m.rules_panel.size, Vector2(1080, 2424))
	assert_eq(m.rules_panel.body_label.position, Vector2(90, 240) + m.hud.position)
	assert_eq(m.rules_panel.close_button.position, Vector2(340, 1360) + m.hud.position)
