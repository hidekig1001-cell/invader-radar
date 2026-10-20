extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_settings_button_text_and_size() -> void:
	var m = await _start()
	assert_eq(m.hud.settings_button.text, "RULES")
	assert_eq(m.hud.settings_button.position, Vector2(720, 260))
	assert_eq(m.hud.settings_button.size, Vector2(320, 100))


## CHECK: 2
func test_settings_pressed_starts_tutorial() -> void:
	var m = await _start()
	m.hud.settings_pressed.emit()
	assert_false(m.is_tutorial())
	assert_true(m.rules_panel.visible)


## CHECK: 3
func test_settings_pressed_does_not_restart_tutorial() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.step_index, 1)
	m.hud.settings_pressed.emit()
	assert_eq(m.tutorial.step_index, 1)
	assert_false(m.rules_panel.visible)


## CHECK: 4
func test_tutorial_finished_signal_emitted() -> void:
	var m = await _start()
	watch_signals(m)
	m.start_tutorial()
	m.end_tutorial()
	assert_signal_emit_count(m, "tutorial_finished", 1)

