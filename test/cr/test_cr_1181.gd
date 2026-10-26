extends GutTest

const LevelScript = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


func _make_level() -> LevelScript:
	var level = LevelScript.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		]
	})
	return level


func _make_main(level: LevelScript) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1181_diagonal_collision_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations.size(), 1)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 1)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)

	m.session.double_tap(1, 1)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)


## CHECK: 2
func test_cr_1181_vertical_collision_and_removal_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.session.double_tap(0, 0)
	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)

	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)

	m.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations.size(), 3)
	assert_eq(m.sound.vibrations[2], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 3)
	assert_eq(m.sound.vibration_amplitudes[2], -1.0)


## CHECK: 3
func test_cr_1181_tutorial_collision_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.start_tutorial()
	assert_not_null(m.tutorial)

	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations.size(), 1)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 1)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)

	m.tutorial.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)
