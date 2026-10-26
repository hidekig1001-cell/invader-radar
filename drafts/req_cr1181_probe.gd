extends GutTest
# CR-1181 の確かめる項目を GUT にした見本（req_cr1181.txt の項目 1〜3 と同じ順）。

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
func test_wrong_vibrates_long_weak() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [30])
	m.session.double_tap(1, 1)
	assert_eq(m.sound.vibrations, [30, 250])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.3])


## CHECK: 2
func test_no_vibrate_on_removing_wrong() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations, [30, 250])
	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations, [30, 250])
	m.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations, [30, 250, 30])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.3, -1.0])


## CHECK: 3
func test_tutorial_wrong_vibrates() -> void:
	var m = await _main()
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations, [30])
	m.tutorial.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations, [30, 250])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.3])
