extends GutTest

func test_title_logo_properties() -> void:
	## CHECK: 1
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1143_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 1920))
	
	assert_eq(ts.title_logo.texture.resource_path, "res://assets/title_logo.png")
	assert_eq(ts.title_logo.position, Vector2(180, 520))
	assert_eq(ts.title_logo.size, Vector2(720, 323))
	assert_true(ts.title_logo.visible)
	assert_false(ts._title_label.visible)
	assert_eq(ts.title_text(), "INVADER RADAR")

func test_title_logo_layout_vertical() -> void:
	## CHECK: 2
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1143_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.apply_screen_layout(Vector2(1080, 2424))
	
	assert_eq(ts.title_logo.position, Vector2(180, 772))
	var logo_rect = Rect2(ts.title_logo.position, ts.title_logo.size)
	var lang_en_rect = Rect2(ts._lang_btn_en.position, ts._lang_btn_en.size)
	var lang_ja_rect = Rect2(ts._lang_btn_ja.position, ts._lang_btn_ja.size)
	assert_false(logo_rect.intersects(lang_en_rect))
	assert_false(logo_rect.intersects(lang_ja_rect))
