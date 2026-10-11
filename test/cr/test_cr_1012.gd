extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _start_tutorial() -> Node2D:
	var m = MainScene.instantiate()
	m.start_with_tutorial = true
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _start_normal() -> Node2D:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_tutorial_starts_with_correct_state() -> void:
	var m = await _start_tutorial()
	assert_true(m.is_tutorial())
	assert_eq(m.board_view.session, m.tutorial.session)
	assert_eq(m.bubble.text, TutorialSteps.steps()[0]["text"])
	assert_eq(m.board_view.highlight_cells, [Vector2i(3, 1)])
	assert_true(m.hud.hint_button.disabled)
	assert_true(m.hud.undo_button.disabled)


## CHECK: 2
func test_normal_start_has_no_tutorial() -> void:
	var m = await _start_normal()
	assert_false(m.is_tutorial())
	assert_eq(m.board_view.session, m.session)


## CHECK: 3
func test_tutorial_input_double_tap_advances_step() -> void:
	var m = await _start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)
	assert_eq(m.bubble.text, TutorialSteps.steps()[1]["text"])
	assert_eq(m.board_view.highlight_cells, TutorialSteps.steps()[1]["highlight"])


## CHECK: 4
func test_tutorial_input_next_via_touch_outside_board() -> void:
	var m = await _start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 400)
	m._input(down)
	
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = Vector2(540, 400)
	m._input(up)
	
	assert_eq(m.tutorial.step_index, 2)


## CHECK: 5
func test_tutorial_ends_and_restores_state() -> void:
	var m = await _start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	m.tutorial_input("next", Vector2i(-1, -1))
	m.tutorial_input("next", Vector2i(-1, -1))
	m.tutorial_input("double_tap", Vector2i(0, 2))
	m.tutorial_input("double_tap", Vector2i(1, 0))
	m.tutorial_input("double_tap", Vector2i(2, 3))
	m.tutorial_input("next", Vector2i(-1, -1))
	
	assert_false(m.is_tutorial())
	assert_eq(m.board_view.session, m.session)
	assert_eq(m.board_view.highlight_cells, [])
	assert_false(m.hud.hint_button.disabled)
	assert_eq(m.session.snapshot()["level"], 1)
