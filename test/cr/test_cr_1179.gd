extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")
const LevelScript = preload("res://game/level.gd")
const SoundScript = preload("res://scenes/sound.gd")

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

func _make_main(levels: Array) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1179_sound_dead_sfx() -> void:
	var s = SoundScript.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("dead")
	assert_eq(s.played, ["dead"])

## CHECK: 2
func test_cr_1179_main_dead_transition() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])

## CHECK: 3
func test_cr_1179_main_dead_with_alien() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [30, 15, 15])
	
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 250])

## CHECK: 4
func test_cr_1179_main_dead_retrigger() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])
	
	m.session.tap(1, 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])
	
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 3)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250, 250])

## CHECK: 5
func test_cr_1179_main_dead_swipe() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [250])

## CHECK: 6
func test_cr_1179_main_dead_next_level() -> void:
	var level_a = _make_level()
	var level_b = _make_level()
	var level_c = _make_level()
	var m = await _make_main([level_a, level_b, level_c])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	m.session.next_level()
	assert_eq(m.session.level_index, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])

## CHECK: 7
func test_cr_1179_main_dead_initial_state() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [15])
	
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [15, 250])

## CHECK: 8
func test_cr_1179_main_dead_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.start_tutorial()
	m.tutorial.session.tap(0, 2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [15])
	
	m.end_tutorial()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [15, 15, 15, 15, 250])
