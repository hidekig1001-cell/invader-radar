extends GutTest

const Tutorial = preload("res://game/tutorial.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")
const MainScene = preload("res://scenes/main.tscn")


## CHECK: 1
func test_cr_1077_check_1() -> void:
	var t = Tutorial.new()
	t.handle("double_tap", Vector2i(3, 1))
	assert_eq(t.step_index, 1)
	assert_eq(t.current_step()["wait"]["kind"], "mark")
	assert_false(t.handle("next", Vector2i(-1, -1)))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(0, 1))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(1, 1))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(2, 1))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(3, 0))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(3, 2))
	assert_eq(t.step_index, 1)
	t.handle("tap", Vector2i(3, 3))
	assert_eq(t.step_index, 2)


## CHECK: 2
func test_cr_1077_check_2() -> void:
	var steps = TutorialSteps.steps()
	assert_eq(steps[1]["text"], "ONE ALIEN PER ROW AND COLUMN, TOO.\nMARK AN X ON THE 6 CELLS.")
	assert_eq(TutorialSteps.apply_language("ja", 1), "各行・各列にも 1 つ。\n6 つのマスに × を付ける")


## CHECK: 3
func test_cr_1077_check_3() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(0, 1))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(1, 1))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(2, 1))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(3, 0))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(3, 2))
	assert_eq(m.tutorial.step_index, 1)
	m.tutorial_input("tap", Vector2i(3, 3))
	assert_eq(m.tutorial.step_index, 2)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 2))
