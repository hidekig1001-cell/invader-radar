extends GutTest
# 使われない last_dead の片づけの確かめる項目を GUT にした見本（req_cleanup_last_dead.txt の項目 1・2 と同じ順）。


func _main():
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = load("res://scenes/main.tscn").instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_last_dead_removed_and_dead_twice() -> void:
	var m = await _main()
	assert_false("last_dead" in m)
	assert_true("last_dead_marks" in m)
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1)
	m.session.tap(2, 2)
	m.session.tap(3, 2)
	m.session.tap(2, 3)
	m.session.tap(3, 3)
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])


## CHECK: 2
func test_last_dead_removed_after_tutorial() -> void:
	var m = await _main()
	m.start_tutorial()
	assert_false("last_dead" in m)
	m.end_tutorial()
	assert_false("last_dead" in m)
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
