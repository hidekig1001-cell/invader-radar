extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")
const LevelScript = preload("res://game/level.gd")

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
func test_cr_1184_sound_line() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("line")
	assert_eq(s.played, ["line"])

## CHECK: 2
func test_cr_1184_line_on_place_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(0, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 3
func test_cr_1184_line_on_mark_completion_and_new_region() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
func test_cr_1184_line_retrigger_on_mark_toggle() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
func test_cr_1184_line_on_alien_removal_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
func test_cr_1184_line_on_alien_removal_and_mark_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
func test_cr_1184_no_line_on_initial_load_with_lines() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
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
func test_cr_1184_line_on_completion_before_clear() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 1, 0)
	m.session.board.apply("place", 3, 1)
	m.session.board.apply("place", 0, 2)
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	m.session.board.apply("mark", 2, 1)
	m.session.board.apply("mark", 1, 2)
	m.session.board.apply("mark", 3, 2)
	m.session.board.apply("mark", 0, 3)
	m.session.board.apply("mark", 1, 3)
	m.session.board.apply("mark", 3, 3)
	add_child_autofree(m)
	await wait_frames(2)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
	m.session.double_tap(2, 3)
	assert_eq(m.session.status, "cleared")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 9
func test_cr_1184_no_line_in_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
func test_cr_1184_dead_priority_over_line() -> void:
	var level = _make_level()
	var m = await _make_main(level)
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
