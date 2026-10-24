extends GutTest

const MainScene = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1145_button_positions_and_board_relation() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	
	assert_eq(m.hud.undo_button.position, Vector2(40, 1506))
	assert_eq(m.hud.restart_button.position, Vector2(380, 1506))
	assert_eq(m.hud.settings_button.position, Vector2(720, 1506))
	assert_eq(m.hud.undo_button.size, Vector2(320, 100))
	
	var board_bg_rect = m.board_view.board_bg_rect()
	assert_true(board_bg_rect.end.y <= m.hud.undo_button.position.y)
	assert_true(m.hud.undo_button.get_rect().end.y <= m.hud.hint_button.position.y)

## CHECK: 2
func test_cr_1145_apply_screen_layout_positions() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	
	m.apply_screen_layout(Vector2(1080, 2424))
	
	assert_eq(m.hud.undo_button.get_global_rect(), Rect2(40, 1758, 320, 100))
	assert_eq(m.hud.settings_button.get_global_rect(), Rect2(720, 1758, 320, 100))
