extends GutTest

const ButtonStyle = preload("res://scenes/button_style.gd")
const TitleScreenScript = preload("res://scenes/title_screen.gd")
const MainScene = preload("res://scenes/main.tscn")
const SpaceBgScript = preload("res://scenes/space_bg.gd")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_make_box_normal_margins() -> void:
	var box = ButtonStyle.make_box("res://assets/buttons/button_normal.png", 0)
	assert_eq(box.texture_margin_left, 32)
	assert_eq(box.texture_margin_right, 32)
	assert_eq(box.texture_margin_top, 44)
	assert_eq(box.texture_margin_bottom, 40)
	assert_eq(box.content_margin_left, 16)
	assert_eq(box.content_margin_right, 16)
	assert_eq(box.content_margin_top, 4)
	assert_eq(box.content_margin_bottom, 4)


## CHECK: 2
func test_make_box_pressed_drop_margins() -> void:
	var box = ButtonStyle.make_box("res://assets/buttons/button_pressed.png", 4)
	assert_eq(box.content_margin_top, 8)
	assert_eq(box.content_margin_bottom, box.content_margin_top - 8)
	assert_eq(box.content_margin_left, 16)
	assert_eq(box.content_margin_right, 16)


## CHECK: 3
func test_make_box_texture_path_and_size() -> void:
	var box = ButtonStyle.make_box("res://assets/buttons/button_pressed.png", 0)
	assert_eq(box.texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_eq(box.texture.get_width(), 360)
	assert_eq(box.texture.get_height(), 140)


## CHECK: 4
func test_apply_to_normal_hover_focus_styleboxes() -> void:
	var btn = Button.new()
	add_child_autofree(btn)
	ButtonStyle.apply_to(btn)
	var normal = btn.get_theme_stylebox("normal")
	var hover = btn.get_theme_stylebox("hover")
	var focus = btn.get_theme_stylebox("focus")
	assert_true(normal is StyleBoxTexture)
	assert_true(hover is StyleBoxTexture)
	assert_true(focus is StyleBoxTexture)
	assert_eq(normal.texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_eq(hover.texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_eq(focus.texture.resource_path, "res://assets/buttons/button_normal.png")


## CHECK: 5
func test_apply_to_pressed_disabled_styleboxes() -> void:
	var btn = Button.new()
	add_child_autofree(btn)
	ButtonStyle.apply_to(btn)
	var pressed = btn.get_theme_stylebox("pressed")
	var disabled = btn.get_theme_stylebox("disabled")
	assert_true(pressed is StyleBoxTexture)
	assert_true(disabled is StyleBoxTexture)
	assert_eq(pressed.texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_eq(disabled.texture.resource_path, "res://assets/buttons/button_disabled.png")


## CHECK: 6
func test_apply_to_font_colors() -> void:
	var btn = Button.new()
	add_child_autofree(btn)
	ButtonStyle.apply_to(btn)
	assert_eq(btn.get_theme_color("font_color"), Color8(74, 50, 10))
	assert_eq(btn.get_theme_color("font_hover_color"), Color8(74, 50, 10))
	assert_eq(btn.get_theme_color("font_pressed_color"), Color8(74, 50, 10))
	assert_eq(btn.get_theme_color("font_disabled_color"), Color8(78, 74, 96))


## CHECK: 7
func test_title_screen_buttons_stylebox() -> void:
	var ts = TitleScreenScript.new()
	add_child_autofree(ts)
	await wait_frames(2)
	assert_true(ts._lang_btn_en.get_theme_stylebox("normal") is StyleBoxTexture)
	assert_eq(ts._lang_btn_en.get_theme_stylebox("normal").texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_true(ts._lang_btn_ja.get_theme_stylebox("normal") is StyleBoxTexture)
	assert_eq(ts._lang_btn_ja.get_theme_stylebox("normal").texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_true(ts._start_btn_tutorial.get_theme_stylebox("normal") is StyleBoxTexture)
	assert_eq(ts._start_btn_tutorial.get_theme_stylebox("normal").texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_true(ts._start_btn_now.get_theme_stylebox("normal") is StyleBoxTexture)
	assert_eq(ts._start_btn_now.get_theme_stylebox("normal").texture.resource_path, "res://assets/buttons/button_normal.png")


## CHECK: 8
func test_hud_buttons_pressed_stylebox() -> void:
	var m = await _start_main()
	assert_true(m.hud.undo_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.undo_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_true(m.hud.settings_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.settings_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_true(m.hud.hint_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.hint_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_true(m.hud.apply_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.apply_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_true(m.hud.restart_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.restart_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")
	assert_true(m.hud.title_button.get_theme_stylebox("pressed") is StyleBoxTexture)
	assert_eq(m.hud.title_button.get_theme_stylebox("pressed").texture.resource_path, "res://assets/buttons/button_pressed.png")


## CHECK: 9
func test_hud_undo_button_normal_margins() -> void:
	var m = await _start_main()
	var normal = m.hud.undo_button.get_theme_stylebox("normal")
	assert_true(normal is StyleBoxTexture)
	assert_eq(normal.texture_margin_left, 32)
	assert_eq(normal.texture_margin_top, 44)


## CHECK: 10
func test_title_button_does_not_intersect_planets() -> void:
	var m = await _start_main()
	var title_btn = m.hud.title_button
	assert_true(title_btn.get_theme_stylebox("normal") is StyleBoxTexture)
	var btn_rect = title_btn.get_rect()
	var space_bg = SpaceBgScript.new()
	var planets = space_bg.planet_list()
	var planet_rects = [
		Rect2(-10, 1490, 260, 260),
		Rect2(60, 1790, 100, 100),
		Rect2(34, 34, 52, 52)
	]
	for i in range(planets.size()):
		var p_rect = planet_rects[i]
		assert_false(btn_rect.intersects(p_rect))
