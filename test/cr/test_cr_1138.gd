extends GutTest

## CHECK: 1
func test_cr_1138_layout_positions() -> void:
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1138_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 1920))
	
	assert_eq(ts.background.position, Vector2(0, 120))
	assert_eq(ts.sound_btn.position, Vector2(760, 240))
	assert_eq(ts.licenses_btn.position, Vector2(390, 1080))
	assert_eq(ts.top_fill.position, Vector2(0, 0))
	assert_eq(ts.top_fill.size, Vector2(1080, 120))
	assert_true(ts.top_fill.color.is_equal_approx(Color(0.03, 0.02, 0.12)))

## CHECK: 2
func test_cr_1138_layout_offsets() -> void:
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1138_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 2424))
	
	assert_eq(ts.background.position, Vector2(0, 372))
	assert_eq(ts.top_fill.size, Vector2(1080, 372))
	assert_eq(ts.licenses_btn.position, Vector2(390, 1332))
	assert_false(Rect2(ts.licenses_btn.position, ts.licenses_btn.size).intersects(Rect2(ts._lang_btn_en.position, ts._lang_btn_en.size)))
	assert_false(Rect2(ts.licenses_btn.position, ts.licenses_btn.size).intersects(Rect2(ts._start_btn_tutorial.position, ts._start_btn_tutorial.size)))
