extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const BoardState = preload("res://core/board_state.gd")


func _tap_cell(m: Node2D, x: int, y: int) -> void:
	var c: Vector2 = m.board_view.cell_rect(x, y).get_center()
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


## CHECK: 1
func test_cr_1013_check_1() -> void:
	var m = MainScene.instantiate()
	m.start_with_tutorial = true
	add_child_autofree(m)
	await wait_frames(2)

	# Step 0 is "double_tap". Tap (2, 0) once.
	_tap_cell(m, 2, 0)
	assert_eq(m.tutorial.step_index, 0)

	# Manually advance to step 1 ("next")
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)

	await wait_frames(30)

	# Tap (0, 0) once. Since step 1 is "next", this should advance to step 2.
	_tap_cell(m, 0, 0)
	assert_eq(m.tutorial.step_index, 2)


## CHECK: 2
func test_cr_1013_check_2() -> void:
	var m = MainScene.instantiate()
	m.start_with_tutorial = true
	add_child_autofree(m)
	await wait_frames(2)

	# Advance to step 1 ("next")
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)

	await wait_frames(30)

	# Tap (0, 0) once to advance to step 2 ("next")
	_tap_cell(m, 0, 0)
	assert_eq(m.tutorial.step_index, 2)

	# Immediately tap (0, 0) again. This should be read as double_tap.
	# In a "next" step, double_tap should do nothing.
	_tap_cell(m, 0, 0)
	assert_eq(m.tutorial.step_index, 2)
	assert_eq(m.tutorial.session.board.state_at(0, 0), BoardState.EMPTY)

	await wait_frames(30)

	# Tap (1, 1) once. Since step 2 is "next", this should advance to step 3.
	_tap_cell(m, 1, 1)
	assert_eq(m.tutorial.step_index, 3)
