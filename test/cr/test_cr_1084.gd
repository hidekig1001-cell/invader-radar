extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1084_tutorial_clears_tile_mode_and_shows_text() -> void:
	var m = await _start()
	m.session.solve_now()
	assert_true(m.bubble.tile_mode)

	m.start_tutorial()
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 0))

	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 1))


## CHECK: 2
func test_cr_1084_refresh_during_tutorial_and_end_restores_tile() -> void:
	var m = await _start()
	m.session.solve_now()
	m.start_tutorial()
	m._refresh()
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, TutorialSteps.apply_language(m.language, 0))

	m.end_tutorial()
	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, m.cleared_text())
