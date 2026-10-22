extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const BoardState = preload("res://core/board_state.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 3
func test_initial_state() -> void:
	var m = await _start()
	assert_not_null(m.hud.apply_button)
	assert_false(m.hud.apply_button.visible)
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))


## CHECK: 1
func test_hint_button_behavior() -> void:
	var m = await _start()
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	assert_eq(m.session.hints, 2)
	assert_eq(m.board_view.hint_cell, Vector2i(1, 0))
	assert_false(m.hud.apply_button.visible)
	assert_eq(m.bubble.text, "A PIECE GOES HERE. DOUBLE TAP TO PLACE IT.")


## CHECK: 2
func test_apply_button_behavior() -> void:
	var m = await _start()
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	m.hud.apply_button.pressed.emit()
	await wait_frames(1)
	assert_eq(m.session.board.state_at(1, 0), BoardState.PIECE)
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))
	assert_false(m.hud.apply_button.visible)


## CHECK: 4
func test_next_level_clears_hint() -> void:
	var m = await _start()
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	m.session.next_level()
	await wait_frames(1)
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))
	assert_false(m.hud.apply_button.visible)
