extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_level() -> Level:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})
	return level


func _make_main(level: Level) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1191_last_dead_removed_and_dead_sound_twice() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	assert_false("last_dead" in m, "last_dead should be removed")
	assert_true("last_dead_marks" in m, "last_dead_marks should remain")

	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1, "first dead group should play 'dead' once")

	m.session.tap(2, 2)
	m.session.tap(3, 2)
	m.session.tap(2, 3)
	m.session.tap(3, 3)
	assert_eq(m.sound.played.count("dead"), 2, "second dead group should play 'dead' again")
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250], "vibrations should match expected pattern")


## CHECK: 2
func test_cr_1191_tutorial_last_dead_removed_and_dead_sound() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.start_tutorial()
	assert_false("last_dead" in m, "last_dead should be removed after start_tutorial")

	m.end_tutorial()
	assert_false("last_dead" in m, "last_dead should be removed after end_tutorial")

	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1, "dead sound should play once after tutorial ends")
	assert_eq(m.sound.vibrations, [15, 15, 15, 250], "vibrations should match expected pattern")
