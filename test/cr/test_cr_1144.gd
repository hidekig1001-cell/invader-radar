extends GutTest

const MainScene = preload("res://scenes/main.tscn")

func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1144_button_positions_and_sizes() -> void:
	var m = await _start()
	assert_eq(m.hud.hint_button.position, Vector2(40, 1614))
	assert_eq(m.hud.hint_button.size, Vector2(320, 100))
	assert_eq(m.hud.apply_button.position, Vector2(40, 1614))
	assert_eq(m.hud.apply_button.size, Vector2(320, 100))
	assert_eq(m.hud.sound_button.position, Vector2(380, 1614))
	assert_eq(m.hud.sound_button.size, Vector2(320, 100))
	assert_eq(m.hud.title_button.position, Vector2(720, 1614))
	assert_eq(m.hud.title_button.size, Vector2(320, 100))
	assert_eq(m.rules_label.position, Vector2(54, 1732))
	assert_eq(m.rules_label.size, Vector2(972, 128))
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 32)

## CHECK: 2
func test_cr_1144_solve_button_and_no_overlap() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 1920))
	assert_eq(m.hud.solve_button.position, Vector2(40, 1866))
	assert_eq(m.hud.solve_button.size, Vector2(200, 50))
	assert_eq(m.hud.solve_button.get_theme_font_size("font_size"), 28)
	assert_false(m.hud.solve_button.get_global_rect().intersects(m.rules_label.get_global_rect()))
	assert_false(m.hud.solve_button.get_global_rect().intersects(m.hud.hint_button.get_global_rect()))
	assert_false(m.hud.sound_button.get_global_rect().intersects(m.hud.title_button.get_global_rect()))
	assert_false(m.hud.sound_button.get_global_rect().intersects(m.hud.apply_button.get_global_rect()))

## CHECK: 3
func test_cr_1144_tall_screen_layout() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(m.hud.hint_button.get_global_rect(), Rect2(40, 1866, 320, 100))
	assert_eq(m.hud.sound_button.get_global_rect(), Rect2(380, 1866, 320, 100))
	assert_eq(m.rules_label.position, Vector2(54, 1984))
	assert_eq(m.hud.solve_button.get_global_rect(), Rect2(40, 2118, 200, 50))
