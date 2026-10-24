extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const BubbleScript = preload("res://scenes/message_bubble.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1086_start_tutorial_shows_panel_and_advances() -> void:
	var m = await _start_main()
	m.start_tutorial()
	assert_true(m.bubble.panel_mode)
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 0))
	assert_eq(m.bubble.size, Vector2(1000, 192))
	assert_eq(m.bubble.position - m.bubble.normal_position, Vector2(0, 0))
	
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_true(m.bubble.panel_mode)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 1))


## CHECK: 2
func test_cr_1086_end_tutorial_restores_bubble() -> void:
	var m = await _start_main()
	var p0 = m.bubble.position
	m.start_tutorial()
	m.end_tutorial()
	assert_false(m.bubble.panel_mode)
	assert_eq(m.bubble.text, m.help_text())
	assert_eq(m.bubble.size, Vector2(1000, 192))
	assert_eq(m.bubble.position, p0)


## CHECK: 3
func test_cr_1086_show_panel_and_clear_text_style() -> void:
	var b = BubbleScript.new()
	add_child_autofree(b)
	await wait_frames(1)
	
	b.show_panel("A")
	assert_true(b.panel_mode)
	assert_ne(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_color("font_color"), BubbleScript.TILE_FONT_COLOR)
	assert_eq(b.get_theme_font_size("font_size"), 48)
	
	b.clear_text()
	assert_false(b.panel_mode)
	assert_eq(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_font_size("font_size"), BubbleScript.FONT_SIZE)


## CHECK: 4
func test_cr_1086_panel_does_not_overlap_ui_or_board() -> void:
	var m = await _start_main()
	m.start_tutorial()
	var r = Rect2(m.bubble.position, m.bubble.size)
	
	var undo_rect = Rect2(m.hud.position + m.hud.undo_button.position, m.hud.undo_button.size)
	assert_false(r.intersects(undo_rect))
	
	var settings_rect = Rect2(m.hud.position + m.hud.settings_button.position, m.hud.settings_button.size)
	assert_false(r.intersects(settings_rect))
	
	var board_rect = Rect2(m.board_view.position + m.board_view.board_rect().position, m.board_view.board_rect().size)
	assert_false(r.intersects(board_rect))
