extends GutTest
# CR-1179 の確かめる項目を GUT にした見本（req_cr1179.txt の項目 1〜8 と同じ順）。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _level():
	var Level = load("res://game/level.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": REGIONS})
	return level


func _main(levels: Array):
	var Main = load("res://scenes/main.tscn")
	var SessionScript = load("res://game/session.gd")
	var m = Main.instantiate()
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_play_sfx_dead() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("dead")
	assert_eq(s.played, ["dead"])


## CHECK: 2
func test_dead_on_region_filled() -> void:
	var m = await _main([_level()])
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])


## CHECK: 3
func test_no_dead_on_row_with_alien() -> void:
	var m = await _main([_level()])
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [30])
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [30, 120])


## CHECK: 4
func test_dead_again_after_back_to_empty() -> void:
	var m = await _main([_level()])
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])
	m.session.tap(1, 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [120, 120])


## CHECK: 5
func test_dead_on_swipe() -> void:
	var m = await _main([_level()])
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])


## CHECK: 6
func test_dead_again_on_next_level() -> void:
	var m = await _main([_level(), _level(), _level()])
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [120])
	m.session.next_level()
	assert_eq(m.session.level_index, 1)
	assert_eq(m.sound.vibrations, [120])
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [120, 120])


## CHECK: 7
func test_no_dead_on_first_refresh() -> void:
	var Main = load("res://scenes/main.tscn")
	var SessionScript = load("res://game/session.gd")
	var m = Main.instantiate()
	m.session = SessionScript.new([_level()])
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])


## CHECK: 8
func test_no_dead_in_tutorial() -> void:
	var m = await _main([_level()])
	m.start_tutorial()
	m.tutorial.session.tap(0, 2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	m.end_tutorial()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])
