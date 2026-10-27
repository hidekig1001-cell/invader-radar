extends GutTest
# × だけの組が新しくできるたびに dead を鳴らす直しの確かめる項目を GUT にした見本（req_bug_dead_new_group.txt の項目 1〜3 と同じ順）。
# main 0ae3435 で流す。直しなし（今の main）では 3 関数とも落ち、try_bug_dead_new_group_patch.py を当てた写しでは通る見込み（このクラウドには Godot が無く、流してはいない）。

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


func _fill_region_0(m) -> void:
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])


## CHECK: 1
func test_dead_on_second_separate_group() -> void:
	var m = await _main()
	_fill_region_0(m)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "mark")
	assert_eq(m.sound.played.count("dead"), 1)
	m.session.tap(3, 2)
	m.session.tap(2, 3)
	m.session.tap(3, 3)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])


## CHECK: 2
func test_dead_on_overlapping_new_group() -> void:
	var m = await _main()
	_fill_region_0(m)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])


## CHECK: 3
func test_dead_on_undo_clear_hand() -> void:
	var m = await _main()
	_fill_region_0(m)
	m.session.double_tap(1, 1)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	m.session.undo()
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 250])
