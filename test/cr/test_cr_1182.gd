extends GutTest

const LevelScript = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


func _make_main_with_level():
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
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1182_dead_vibration_duration_and_amplitude() -> void:
	var m = await _make_main_with_level()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])


## CHECK: 2
func test_cr_1182_dead_vibration_on_swipe() -> void:
	var m = await _make_main_with_level()
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.sound.vibration_amplitudes, [0.3])


## CHECK: 3
func test_cr_1182_dead_vibration_not_retriggered() -> void:
	var m = await _make_main_with_level()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4])
