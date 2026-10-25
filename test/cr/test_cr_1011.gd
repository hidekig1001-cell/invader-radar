extends GutTest

const TutorialSteps = preload("res://game/tutorial_steps.gd")
const Tutorial = preload("res://game/tutorial.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_steps_structure() -> void:
	var steps = TutorialSteps.steps()
	assert_eq(steps.size(), 6)
	assert_eq(steps[0]["wait"], {"kind": "double_tap", "cell": Vector2i(3, 1)})
	assert_eq(steps[4]["wait"], {"kind": "solved"})


## CHECK: 2
func test_practice_level_data_and_solution() -> void:
	var level_data = TutorialSteps.practice_level()
	assert_eq(level_data["regions"], [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]])
	var level = Level.new()
	level.parse(level_data)
	assert_eq(Solver.count_solutions(level), 1)


## CHECK: 3
func test_initial_state() -> void:
	var t = Tutorial.new()
	assert_eq(t.step_index, 0)
	assert_false(t.is_finished())
	assert_eq(t.current_step()["text"], "EACH COLOR NEEDS ONE ALIEN.\nDOUBLE TAP THE GREEN CELL.")
	assert_eq(t.session.board.state_at(3, 1), BoardState.EMPTY)


## CHECK: 4
func test_step_0_interactions() -> void:
	var t = Tutorial.new()
	assert_false(t.handle("tap", Vector2i(3, 1)))
	assert_false(t.handle("double_tap", Vector2i(0, 0)))
	assert_eq(t.step_index, 0)
	assert_eq(t.session.board.state_at(3, 1), BoardState.EMPTY)
	assert_eq(t.session.board.state_at(0, 0), BoardState.EMPTY)
	
	assert_true(t.handle("double_tap", Vector2i(3, 1)))
	assert_eq(t.step_index, 1)
	assert_eq(t.session.board.state_at(3, 1), BoardState.PIECE)


## CHECK: 5
func test_step_1_interactions() -> void:
	var t = Tutorial.new()
	t.handle("double_tap", Vector2i(3, 1))
	
	assert_false(t.handle("double_tap", Vector2i(1, 0)))
	assert_eq(t.step_index, 1)
	
	assert_false(t.handle("next", Vector2i(-1, -1)))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(0, 1))
	t.handle("tap", Vector2i(1, 1))
	t.handle("tap", Vector2i(2, 1))
	t.handle("tap", Vector2i(3, 0))
	t.handle("tap", Vector2i(3, 2))
	t.handle("tap", Vector2i(3, 3))
	assert_eq(t.step_index, 2)


## CHECK: 6
func test_steps_0_to_4_progression() -> void:
	var t = Tutorial.new()
	t.handle("double_tap", Vector2i(3, 1))
	t.handle("tap", Vector2i(0, 1))
	t.handle("tap", Vector2i(1, 1))
	t.handle("tap", Vector2i(2, 1))
	t.handle("tap", Vector2i(3, 0))
	t.handle("tap", Vector2i(3, 2))
	t.handle("tap", Vector2i(3, 3))
	t.handle("tap", Vector2i(2, 0))
	t.handle("tap", Vector2i(2, 2))
	t.handle("double_tap", Vector2i(0, 2))
	assert_eq(t.step_index, 4)
	
	assert_true(t.handle("double_tap", Vector2i(1, 0)))
	assert_eq(t.step_index, 4)
	
	assert_true(t.handle("double_tap", Vector2i(2, 3)))
	assert_eq(t.step_index, 5)


## CHECK: 7
func test_finish_tutorial() -> void:
	var t = Tutorial.new()
	t.handle("double_tap", Vector2i(3, 1))
	t.handle("tap", Vector2i(0, 1))
	t.handle("tap", Vector2i(1, 1))
	t.handle("tap", Vector2i(2, 1))
	t.handle("tap", Vector2i(3, 0))
	t.handle("tap", Vector2i(3, 2))
	t.handle("tap", Vector2i(3, 3))
	t.handle("tap", Vector2i(2, 0))
	t.handle("tap", Vector2i(2, 2))
	t.handle("double_tap", Vector2i(0, 2))
	t.handle("double_tap", Vector2i(1, 0))
	t.handle("double_tap", Vector2i(2, 3))
	
	assert_true(t.handle("next", Vector2i(-1, -1)))
	assert_true(t.is_finished())
	assert_eq(t.current_step(), {})
	assert_false(t.handle("next", Vector2i(-1, -1)))
