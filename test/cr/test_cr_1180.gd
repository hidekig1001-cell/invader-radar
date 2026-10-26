extends GutTest

const Level = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")

func _make_level() -> Level:
	var level = Level.new()
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

func _make_main(level: Level) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1180_sound_vibrate_amplitude() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.vibrate(30)
	s.vibrate(15, 0.4)
	assert_eq(s.vibrations, [30, 15])
	assert_eq(s.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 2
func test_cr_1180_main_vibrate_on_place_and_mark() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [30])
	assert_eq(m.sound.vibration_amplitudes, [-1.0])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 3
func test_cr_1180_main_vibrate_sequence() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15])
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [15, 30])
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [15, 30])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15, 30, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, -1.0, 0.4])

## CHECK: 4
func test_cr_1180_main_vibrate_on_swipe() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	assert_eq(m.sound.vibrations, [15])
	assert_eq(m.sound.vibration_amplitudes, [0.4])

## CHECK: 5
func test_cr_1180_main_vibrate_in_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations, [30])
	m.tutorial.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 6
func test_cr_1180_main_vibrate_on_dead_transition() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, -1.0])
