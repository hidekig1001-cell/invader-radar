extends GutTest

## CHECK: 1
func test_sound_vibrate_records_ms() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	assert_eq(s.vibrations, [])
	s.vibrate(30)
	assert_eq(s.vibrations, [30])

## CHECK: 2
func test_main_vibrates_on_place_not_mark() -> void:
	var Main = load("res://scenes/main.tscn")
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	
	# Place alien (double tap) -> should vibrate
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [30])
	
	# Mark X (tap) -> should NOT add vibration
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [30])
