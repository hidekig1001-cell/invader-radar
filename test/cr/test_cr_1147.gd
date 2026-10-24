extends GutTest

func test_cr_1147_initial_layout() -> void:
	## CHECK: 1
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1147_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 1920))
	
	assert_eq(ts.background.position, Vector2(0, 120))
	assert_eq(ts.background.size, Vector2(1080, 1800))
	assert_eq(ts.background.expand_mode, TextureRect.EXPAND_IGNORE_SIZE)
	assert_eq(ts.sound_btn.position, Vector2(570, 1080))
	assert_eq(ts.sound_btn.size, Vector2(360, 90))
	assert_eq(ts.licenses_btn.position, Vector2(150, 1080))
	assert_eq(ts.licenses_btn.size, Vector2(360, 90))
	assert_false(Rect2(ts.sound_btn.position, ts.sound_btn.size).intersects(Rect2(ts._lang_btn_ja.position, ts._lang_btn_ja.size)))
	assert_false(Rect2(ts.sound_btn.position, ts.sound_btn.size).intersects(Rect2(ts.licenses_btn.position, ts.licenses_btn.size)))

func test_cr_1147_tall_layout() -> void:
	## CHECK: 2
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1147_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 2424))
	
	assert_eq(ts.background.position, Vector2(0, 372))
	assert_eq(ts.background.size, Vector2(1080, 2052))
	assert_eq(ts.sound_btn.position, Vector2(570, 1332))
	assert_eq(ts.licenses_btn.position, Vector2(150, 1332))
	assert_false(Rect2(ts.sound_btn.position, ts.sound_btn.size).intersects(Rect2(ts._start_btn_tutorial.position, ts._start_btn_tutorial.size)))
