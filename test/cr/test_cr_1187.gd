extends GutTest

const Level = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")

func _make_level() -> Level:
	var level = Level.new()
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

func _make_main(level: Level) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1187_new_dead_group_region() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Tap in region 3 (not forming a new dead group yet, just marking)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "mark")
	assert_eq(m.sound.played.count("dead"), 1)
	
	# Complete region 3 with X
	m.session.tap(3, 2)
	m.session.tap(2, 3)
	m.session.tap(3, 3)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])

## CHECK: 2
func test_cr_1187_new_dead_group_line() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Fill row 0 in region 1 (cells 2,0 and 3,0). This creates a new dead group (row 0 is all X).
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])

## CHECK: 3
func test_cr_1187_undo_dead_group() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Double tap (1,1) to place alien. Region 0 is no longer all X.
	m.session.double_tap(1, 1)
	assert_eq(m.sound.played[-1], "line") # Or whatever sfx corresponds to clearing the dead state / placing alien. The prompt says "line" for this step in test 3 description? 
	# Wait, prompt says: "m.session.double_tap(1, 1) をしたあと... m.sound.played[-1] は \"line\""
	assert_eq(m.sound.vibrations, [15, 15, 15, 250]) # No new vibration for line? Or maybe line has no vibration in this context? 
	# Actually, looking at CR-1187 description: "sfx_name が \"mark\" か \"clear\" で... sfx_name を \"dead\" にする".
	# If we place an alien, it's a "place" or "line" event. It removes the dead state.
	# The prompt explicitly says: m.sound.played[-1] は "line", m.sound.vibrations は [15, 15, 15, 250].
	# This implies the double_tap triggered a "line" sound (maybe because it completed a line? No, region 0 is not a line. 
	# Ah, `Rules.filled_lines` might consider the row/col if they are full? 
	# Let's trust the prompt's expected values.
	
	# Undo: (1,1) becomes X again. Region 0 is all X again. This is a "clear" action effectively restoring the dead state.
	m.session.undo()
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 250])
