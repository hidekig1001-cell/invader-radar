extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const BoardState = preload("res://core/board_state.gd")

func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1083_check_1() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)

	# Touch (0, 0) - should be ignored because it's not highlighted in step 1
	var c: Vector2 = m.board_view.global_position + m.board_view.cell_rect(0, 0).get_center()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = c
	m._input(down)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = c
	m._input(up)

	assert_eq(m.tutorial.session.board.state_at(0, 0), BoardState.EMPTY)
	assert_eq(m.tutorial.step_index, 1)

	# Touch valid cells to advance step
	var cells_to_touch = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 3)]
	for cell in cells_to_touch:
		await wait_frames(30)
		var pos: Vector2 = m.board_view.global_position + m.board_view.cell_rect(cell.x, cell.y).get_center()
		down.position = pos
		m._input(down)
		up.position = pos
		m._input(up)

	assert_eq(m.tutorial.session.board.state_at(3, 3), BoardState.MARK)
	assert_eq(m.tutorial.step_index, 2)

## CHECK: 2
func test_cr_1083_check_2() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	
	var cells_to_touch = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 3)]
	for cell in cells_to_touch:
		m.tutorial_input("tap", cell)
		
	assert_eq(m.tutorial.step_index, 2)

	# Touch (0, 0) - should be ignored because it's not highlighted in step 2
	var c: Vector2 = m.board_view.global_position + m.board_view.cell_rect(0, 0).get_center()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = c
	m._input(down)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = c
	m._input(up)

	assert_eq(m.tutorial.session.board.state_at(0, 0), BoardState.EMPTY)
	assert_eq(m.tutorial.step_index, 2)

	# Touch (2, 0) - should be accepted because it is highlighted in step 2
	await wait_frames(30)
	var pos: Vector2 = m.board_view.global_position + m.board_view.cell_rect(2, 0).get_center()
	down.position = pos
	m._input(down)
	up.position = pos
	m._input(up)

	assert_eq(m.tutorial.session.board.state_at(2, 0), BoardState.MARK)

## CHECK: 3
func test_cr_1083_check_3() -> void:
	var m = await _start()
	m.start_tutorial()
	
	# Step 0 highlights (3, 1). (0, 0) is not highlighted.
	assert_false(m.tutorial_accepts_cell(Vector2i(0, 0)))
	assert_true(m.tutorial_accepts_cell(Vector2i(3, 1)))

	# Step 4 has no highlight (empty array), so all cells are accepted.
	m.tutorial.step_index = 4
	assert_true(m.tutorial_accepts_cell(Vector2i(1, 0)))

	# After tutorial ends, tutorial is null, so all cells are accepted.
	m.end_tutorial()
	assert_true(m.tutorial_accepts_cell(Vector2i(0, 0)))
