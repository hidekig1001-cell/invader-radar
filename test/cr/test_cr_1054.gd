extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const HudScript = preload("res://scenes/hud.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_row_button_positions_and_sizes() -> void:
	var m = await _start()
	assert_eq(m.hud.undo_button.position, Vector2(40, 1506))
	assert_eq(m.hud.restart_button.position, Vector2(380, 1506))
	assert_eq(m.hud.settings_button.position, Vector2(720, 1506))
	assert_eq(m.hud.undo_button.size, Vector2(320, 100))
	assert_eq(m.hud.restart_button.size, Vector2(320, 100))
	assert_eq(m.hud.settings_button.size, Vector2(320, 100))


## CHECK: 2
func test_row_button_font_size_and_min_width() -> void:
	var m = await _start()
	var undo_min_x = m.hud.undo_button.get_combined_minimum_size().x
	var restart_min_x = m.hud.restart_button.get_combined_minimum_size().x
	var settings_min_x = m.hud.settings_button.get_combined_minimum_size().x

	assert_true(undo_min_x <= 320)
	assert_true(restart_min_x <= 320)
	assert_true(settings_min_x <= 320)

	assert_true(undo_min_x > 0)
	assert_true(restart_min_x > 0)
	assert_true(settings_min_x > 0)

	var undo_font = m.hud.undo_button.get_theme_font_size("font_size")
	var restart_font = m.hud.restart_button.get_theme_font_size("font_size")
	var settings_font = m.hud.settings_button.get_theme_font_size("font_size")

	assert_eq(undo_font, restart_font)
	assert_eq(restart_font, settings_font)
	assert_true(undo_font >= 1 and undo_font <= 52)


## CHECK: 3
func test_row_button_global_rects_and_intersections() -> void:
	var m = await _start()
	var undo_rect = m.hud.undo_button.get_global_rect()
	var restart_rect = m.hud.restart_button.get_global_rect()
	var settings_rect = m.hud.settings_button.get_global_rect()

	assert_eq(undo_rect, Rect2(40, 1506, 320, 100))
	assert_eq(restart_rect, Rect2(380, 1506, 320, 100))
	assert_eq(settings_rect, Rect2(720, 1506, 320, 100))

	assert_false(undo_rect.intersects(restart_rect))
	assert_false(settings_rect.intersects(restart_rect))
	assert_true(undo_rect.intersects(Rect2(40, 1506, 320, 100)))


## CHECK: 4
func test_row_buttons_relative_to_moves_label_and_board() -> void:
	var m = await _start()
	var moves_rect = m.hud.moves_label.get_global_rect()
	var undo_rect = m.hud.undo_button.get_global_rect()
	var restart_rect = m.hud.restart_button.get_global_rect()
	var settings_rect = m.hud.settings_button.get_global_rect()

	assert_false(undo_rect.intersects(moves_rect))
	assert_false(restart_rect.intersects(moves_rect))
	assert_false(settings_rect.intersects(moves_rect))

	assert_eq(undo_rect.position.y, 1506)
	assert_eq(restart_rect.position.y, 1506)
	assert_eq(settings_rect.position.y, 1506)

	assert_true(undo_rect.position.y > 250)
	assert_true(restart_rect.position.y > 250)
	assert_true(settings_rect.position.y > 250)

	assert_true(undo_rect.position.y >= 1494)
	assert_true(restart_rect.position.y >= 1494)
	assert_true(settings_rect.position.y >= 1494)


## CHECK: 5
func test_row_buttons_after_apply_screen_layout() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	await wait_frames(2)

	var undo_rect = m.hud.undo_button.get_global_rect()
	var restart_rect = m.hud.restart_button.get_global_rect()
	var settings_rect = m.hud.settings_button.get_global_rect()

	assert_eq(undo_rect, Rect2(40, 1758, 320, 100))
	assert_eq(restart_rect, Rect2(380, 1758, 320, 100))
	assert_eq(settings_rect, Rect2(720, 1758, 320, 100))
