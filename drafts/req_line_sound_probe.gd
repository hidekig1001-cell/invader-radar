extends GutTest
# 手触り 2 本目・音（line）の確かめる項目を GUT にした見本（req_line_sound.txt の項目 1〜10 と同じ順）。
# 1179・1180〜1182 と、手触り 2 本目の規則（Rules.filled_lines）が入った main で流す。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _level():
	var Level = load("res://game/level.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": REGIONS})
	return level


func _new_main():
	var Main = load("res://scenes/main.tscn")
	var SessionScript = load("res://game/session.gd")
	var m = Main.instantiate()
	m.session = SessionScript.new([_level()])
	return m


func _main():
	var m = _new_main()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_play_sfx_line() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("line")
	assert_eq(s.played, ["line"])


## CHECK: 2
func test_line_on_place_hand() -> void:
	var m = await _main()
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(0, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 3
func test_line_on_mark_hand_and_second_group() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 2)


## CHECK: 4
func test_line_again_after_removing_mark() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 2)


## CHECK: 5
func test_line_when_red_alien_removed() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.double_tap(0, 2)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(0, 2)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 6
func test_no_line_with_two_aliens() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.double_tap(2, 0)
	m.session.tap(1, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(2, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(2, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 7
func test_no_line_on_first_refresh() -> void:
	var m = _new_main()
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 8
func test_level_clear_wins_over_line() -> void:
	var m = _new_main()
	m.session.board.apply("place", 1, 0)
	m.session.board.apply("place", 3, 1)
	m.session.board.apply("place", 0, 2)
	for y in range(4):
		for x in range(4):
			if m.session.board.state_at(x, y) == 0 and not (Vector2i(x, y) in [Vector2i(2, 2), Vector2i(2, 3)]):
				m.session.board.apply("mark", x, y)
	add_child_autofree(m)
	await wait_frames(2)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
	m.session.double_tap(2, 3)
	assert_eq(m.session.status, "cleared")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 9
func test_no_line_in_tutorial() -> void:
	var m = await _main()
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.played.count("line"), 0)
	m.end_tutorial()
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)


## CHECK: 10
func test_dead_wins_over_line() -> void:
	var m = await _main()
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 1)
	m.session.tap(3, 2)
	m.session.tap(3, 3)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
