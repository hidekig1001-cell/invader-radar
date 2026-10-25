extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1153_button_positions_and_sizes() -> void:
	var m = await _start()
	assert_eq(Rect2(m.hud.hint_button.position, m.hud.hint_button.size), Rect2(40, 1614, 320, 100))
	assert_eq(Rect2(m.hud.sound_button.position, m.hud.sound_button.size), Rect2(380, 1614, 320, 100))
	assert_eq(Rect2(m.hud.title_button.position, m.hud.title_button.size), Rect2(720, 1614, 320, 100))
	assert_eq(Rect2(m.hud.apply_button.position, m.hud.apply_button.size), Rect2(40, 1614, 320, 100))
	assert_false(m.hud.apply_button.visible)
	assert_eq(m.hud.title_button.text, "BACK TO TITLE")
	assert_true(m.hud.title_button.get_combined_minimum_size().y <= 100.0)
	assert_eq(m.hud.hint_button.position.x, m.hud.undo_button.position.x)
	assert_eq(m.hud.sound_button.position.x, m.hud.restart_button.position.x)
	assert_eq(m.hud.title_button.position.x, m.hud.settings_button.position.x)
	assert_eq(m.hud.hint_button.size, m.hud.undo_button.size)
	assert_false(Rect2(m.hud.hint_button.position, m.hud.hint_button.size).intersects(Rect2(m.hud.sound_button.position, m.hud.sound_button.size)))
	assert_false(Rect2(m.hud.sound_button.position, m.hud.sound_button.size).intersects(Rect2(m.hud.title_button.position, m.hud.title_button.size)))
	assert_false(Rect2(m.hud.undo_button.position, m.hud.undo_button.size).intersects(Rect2(m.hud.hint_button.position, m.hud.hint_button.size)))


## CHECK: 2
func test_cr_1153_tall_screen_layout() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(m.hud.hint_button.get_global_rect(), Rect2(40, 1866, 320, 100))
	assert_eq(m.hud.sound_button.get_global_rect(), Rect2(380, 1866, 320, 100))
	assert_eq(m.hud.title_button.get_global_rect(), Rect2(720, 1866, 320, 100))
	assert_false(m.hud.title_button.get_global_rect().intersects(m.rules_label.get_global_rect()))
