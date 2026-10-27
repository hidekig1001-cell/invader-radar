extends GutTest
# 立ち上げの最初の _refresh で音と振動を出さない直しの確かめる項目を GUT にした見本（req_quiet_first_refresh.txt の項目 1〜3 と同じ順）。
# main 9193cdf（1188 が入れば v1.97）で流す。直しなしでは 3 関数とも落ち、try_quiet_first_refresh_patch.py を当てた写しでは通る見込み（このクラウドには Godot が無く、流してはいない）。


func _main_with(applies: Array):
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var Main = load("res://scenes/main.tscn")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	for a in applies:
		m.session.board.apply(a[0], a[1], a[2])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_quiet_start_with_piece_and_marks() -> void:
	var m = await _main_with([["place", 0, 0], ["mark", 1, 0], ["mark", 2, 0]])
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(3, 1)
	assert_eq(m.sound.played, ["mark"])
	assert_eq(m.sound.vibrations, [15])


## CHECK: 2
func test_quiet_start_with_conflict() -> void:
	var m = await _main_with([["place", 0, 0], ["place", 1, 1]])
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])


## CHECK: 3
func test_quiet_start_with_dead_group() -> void:
	var m = await _main_with([["mark", 0, 0], ["mark", 1, 0], ["mark", 0, 1], ["mark", 1, 1]])
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played, ["dead"])
	assert_eq(m.sound.vibrations, [250])
