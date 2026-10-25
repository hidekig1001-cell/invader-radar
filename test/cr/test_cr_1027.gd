extends GutTest

const TutorialSteps = preload("res://game/tutorial_steps.gd")
const Tutorial = preload("res://game/tutorial.gd")


func _make_tutorial_at_step(step_index: int) -> Tutorial:
	var t = Tutorial.new()
	t.step_index = step_index
	return t


## CHECK: 1
func test_cr_1027_check_1() -> void:
	var steps = TutorialSteps.steps()
	assert_eq(steps[2]["text"], "ALIENS CANNOT TOUCH DIAGONALLY EITHER.\nMARK AN X ON EACH DIAGONAL CELL.")
	assert_eq(steps[2]["highlight"], TutorialSteps.mark_cells())


## CHECK: 2
func test_cr_1027_check_2() -> void:
	var steps = TutorialSteps.steps()
	assert_eq(steps[2]["wait"]["kind"], "mark")
	assert_eq(TutorialSteps.mark_cells(), [Vector2i(2, 0), Vector2i(2, 2)])


## CHECK: 3
func test_cr_1027_check_3() -> void:
	var cells = TutorialSteps.diagonal_cells(Vector2i(2, 1), 4, 4)
	cells.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
	assert_eq(cells, [Vector2i(1, 0), Vector2i(1, 2), Vector2i(3, 0), Vector2i(3, 2)])


## CHECK: 4
func test_cr_1027_check_4() -> void:
	var cells = TutorialSteps.diagonal_cells(Vector2i(0, 0), 4, 4)
	cells.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
	assert_eq(cells, [Vector2i(1, 1)])


## CHECK: 5
func test_cr_1027_check_5() -> void:
	var t = Tutorial.new()
	assert_false(t.step_has_mark_cells())
	t.handle("double_tap", Vector2i(3, 1))
	t.handle("tap", Vector2i(0, 1))
	t.handle("tap", Vector2i(1, 1))
	t.handle("tap", Vector2i(2, 1))
	t.handle("tap", Vector2i(3, 0))
	t.handle("tap", Vector2i(3, 2))
	t.handle("tap", Vector2i(3, 3))
	assert_eq(t.step_index, 2)
	assert_true(t.step_has_mark_cells())


## CHECK: 6
func test_cr_1027_check_6() -> void:
	var t = Tutorial.new()
	assert_false(t.marks_covered(TutorialSteps.mark_cells()))
	t.session.tap(2, 0)
	assert_false(t.marks_covered(TutorialSteps.mark_cells()))
	t.session.tap(2, 2)
	assert_true(t.marks_covered(TutorialSteps.mark_cells()))


## CHECK: 7
func test_cr_1027_check_7() -> void:
	var t = _make_tutorial_at_step(2)
	t.handle("tap", Vector2i(2, 0))
	assert_true(t.marks_covered([Vector2i(2, 0)]))
	assert_eq(t.step_index, 2)


## CHECK: 8
func test_cr_1027_check_8() -> void:
	var t = _make_tutorial_at_step(2)
	t.handle("tap", Vector2i(2, 0))
	t.handle("tap", Vector2i(2, 2))
	assert_true(t.marks_covered(TutorialSteps.mark_cells()))
	assert_eq(t.step_index, 3)


## CHECK: 9
func test_cr_1027_check_9() -> void:
	var t = _make_tutorial_at_step(2)
	t.handle("double_tap", Vector2i(2, 0))
	assert_false(t.marks_covered([Vector2i(2, 0)]))
	assert_eq(t.step_index, 2)


## CHECK: 10
func test_cr_1027_check_10() -> void:
	var t = _make_tutorial_at_step(2)
	t.handle("tap", Vector2i(1, 1))
	assert_true(t.marks_covered([Vector2i(1, 1)]))
	assert_false(t.marks_covered(TutorialSteps.mark_cells()))
	assert_eq(t.step_index, 2)
