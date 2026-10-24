extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const AppScene = preload("res://scenes/app.tscn")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_hint_button_position_and_no_overlap_with_title() -> void:
	var m = await _start_main()
	assert_eq(m.hud.hint_button.position, Vector2(40, 1614))
	assert_eq(m.hud.hint_button.size, Vector2(300, 110))
	assert_false(m.hud.hint_button.get_rect().intersects(m.hud.title_button.get_rect()))


## CHECK: 2
func test_apply_button_position_and_no_overlap_with_title() -> void:
	var m = await _start_main()
	assert_eq(m.hud.apply_button.position, Vector2(350, 1614))
	assert_eq(m.hud.apply_button.size, Vector2(160, 110))
	assert_false(m.hud.apply_button.get_rect().intersects(m.hud.title_button.get_rect()))


## CHECK: 3
func test_font_sizes() -> void:
	var m = await _start_main()
	assert_eq(m.hud.apply_button.get_theme_font_size("font_size"), 40)
	assert_eq(m.hud.title_button.get_theme_font_size("font_size"), 36)
	assert_true(m.hud.apply_button.get_theme_stylebox("normal") is StyleBoxTexture)
	assert_eq((m.hud.apply_button.get_theme_stylebox("normal") as StyleBoxTexture).texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_eq(m.hud.apply_button.get_theme_color("font_color"), Color8(74, 50, 10))
	assert_eq(m.hud.apply_button.get_theme_color("font_disabled_color"), Color8(78, 74, 96))


## CHECK: 4
func test_title_button_text_and_rect() -> void:
	var m = await _start_main()
	assert_eq(m.hud.title_button.text, "BACK TO\nTITLE")
	assert_eq(m.hud.title_button.position, Vector2(810, 1614))
	assert_eq(m.hud.title_button.size, Vector2(230, 110))


## CHECK: 5
func test_title_button_stylebox() -> void:
	var m = await _start_main()
	var sb: StyleBoxTexture = m.hud.title_button.get_theme_stylebox("normal")
	assert_true(sb is StyleBoxTexture)
	assert_eq(sb.texture.resource_path, "res://assets/buttons/button_normal.png")


## CHECK: 6
func test_title_requested_signal_emitted() -> void:
	var m = await _start_main()
	watch_signals(m)
	assert_signal_not_emitted(m, "title_requested")
	m.hud.title_button.pressed.emit()
	assert_signal_emitted(m, "title_requested")


## CHECK: 7
func test_show_title_replaces_main_with_title_screen() -> void:
	var app = AppScene.instantiate()
	add_child_autofree(app)
	await wait_frames(2)
	app.start_game(false)
	await wait_frames(2)
	app.main.hud.title_button.pressed.emit()
	await wait_frames(2)
	assert_false(is_instance_valid(app.main))
	assert_not_null(app.title_screen)
	assert_eq(app.title_screen.language(), "")


## CHECK: 8
func test_start_requested_restarts_game_with_tutorial() -> void:
	var app = AppScene.instantiate()
	add_child_autofree(app)
	await wait_frames(2)
	app.start_game(false)
	await wait_frames(2)
	app.main.hud.title_button.pressed.emit()
	await wait_frames(2)
	app.title_screen.start_requested.emit(true)
	await wait_frames(2)
	assert_true(is_instance_valid(app.main))
	assert_true(app.main.start_with_tutorial)
	assert_eq(app.main.language, "en")


## CHECK: 9
func test_buttons_no_overlap_with_left_area() -> void:
	var m = await _start_main()
	var left_area := Rect2(-10, 1490, 260, 260)
	assert_false(m.hud.apply_button.get_rect().intersects(left_area))
	assert_false(m.hud.title_button.get_rect().intersects(left_area))


## CHECK: 10
func test_title_button_no_overlap_with_rules_label() -> void:
	var m = await _start_main()
	assert_false(m.hud.title_button.get_rect().intersects(m.rules_label.get_rect()))
