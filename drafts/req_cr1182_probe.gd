extends GutTest
# CR-1182 の確かめる項目を GUT にした見本（req_cr1182.txt の項目 1〜3 と同じ順）。CR-1179・CR-1180 が入った main で流す。

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
func test_dead_vibrates_long_weak() -> void:
	var m = await _main()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])


## CHECK: 2
func test_dead_on_swipe_vibrates_long_weak() -> void:
	var m = await _main()
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.sound.vibration_amplitudes, [0.3])


## CHECK: 3
func test_mark_after_dead_vibrates_small() -> void:
	var m = await _main()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4])
