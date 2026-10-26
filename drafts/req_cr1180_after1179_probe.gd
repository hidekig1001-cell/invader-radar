extends GutTest
# CR-1180（CR-1179 の後の版）の確かめる項目を GUT にした見本（req_cr1180_after1179.txt の項目 1〜6 と同じ順）。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _main():
	var Level = load("res://game/level.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": REGIONS})
	var Main = load("res://scenes/main.tscn")
	var SessionScript = load("res://game/session.gd")
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_vibrate_records_amplitude() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.vibrate(30)
	s.vibrate(15, 0.4)
	assert_eq(s.vibrations, [30, 15])
	assert_eq(s.vibration_amplitudes, [-1.0, 0.4])


## CHECK: 2
func test_mark_vibrates_small() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [30])
	assert_eq(m.sound.vibration_amplitudes, [-1.0])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])


## CHECK: 3
func test_no_vibrate_on_remove() -> void:
	var m = await _main()
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
func test_swipe_vibrates_once() -> void:
	var m = await _main()
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	assert_eq(m.sound.vibrations, [15])
	assert_eq(m.sound.vibration_amplitudes, [0.4])


## CHECK: 5
func test_tutorial_mark_vibrates() -> void:
	var m = await _main()
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations, [30])
	m.tutorial.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])


## CHECK: 6
func test_dead_hand_vibrates_only_dead() -> void:
	var m = await _main()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, -1.0])
