extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


func test_hint_button_behavior() -> void:
	## CHECK: 1
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	
	assert_eq(m.board_view.hint_cell, Vector2i(1, 0))
	assert_false(m.hud.apply_button.visible)
	assert_eq(m.bubble.text, "AN ALIEN GOES HERE. DOUBLE TAP TO PLACE IT.")
	
	m.session.tap(3, 3)
	await wait_frames(1)
	
	assert_true(m.session.current_hint.is_empty())
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))
	assert_eq(m.bubble.text, m.help_text())


func test_session_hint_clear_on_tap_and_undo() -> void:
	## CHECK: 2
	var s = SessionScript.new()
	
	s.request_hint()
	assert_false(s.current_hint.is_empty())
	
	s.tap(3, 3)
	assert_true(s.current_hint.is_empty())
	
	s.request_hint()
	assert_false(s.current_hint.is_empty())
	
	s.undo()
	assert_true(s.current_hint.is_empty())


func test_refresh_clears_bubble_on_board_change() -> void:
	## CHECK: 3
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	
	m.session.current_hint = {}
	m._refresh()
	assert_eq(m.bubble.text, m.help_text())
	
	m.board_view.hint_cell = Vector2i(1, 0)
	m.session.status = "cleared"
	m._refresh()
	assert_eq(m.bubble.text, m.cleared_text())
	assert_true(m.bubble.visible)
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))
