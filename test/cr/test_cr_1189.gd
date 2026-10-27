extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const Main = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1189_no_sfx_on_initial_refresh_with_alien_and_marks() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 2, 0)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(3, 1)
	assert_eq(m.sound.played, ["mark"])
	assert_eq(m.sound.vibrations, [15])

## CHECK: 2
func test_cr_1189_no_sfx_on_initial_refresh_with_collision() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("place", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])

## CHECK: 3
func test_cr_1189_no_sfx_on_initial_refresh_with_dead_marks() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played, ["dead"])
	assert_eq(m.sound.vibrations, [250])
