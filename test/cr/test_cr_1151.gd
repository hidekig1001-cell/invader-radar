extends GutTest

const RulesPages = preload("res://scenes/rules_pages.gd")
const TitleScreen = preload("res://scenes/title_screen.gd")

## CHECK: 1
func test_cr_1151_rules_pages_text_and_sound_null() -> void:
	var rp = RulesPages.new()
	rp.language = "ja"
	add_child_autofree(rp)
	await wait_frames(1)
	
	assert_eq(rp.text_label.text, "盤のマスに宇宙人を置こう。\n宇宙人をすべて見つけるとクリア！")
	
	rp.show_page(3)
	assert_eq(rp.text_label.text, "宇宙人どうしは、縦・横・斜めに\n隣り合えない。")
	
	rp.show_page(6)
	assert_eq(rp.text_label.text, "1 回タップで × を付ける。\n2 回タップで宇宙人を置く。")
	
	rp.language = "en"
	rp.show_page(0)
	assert_eq(rp.text_label.text, "PLACE THE ALIENS ON THE BOARD.\nFIND ALL THE ALIENS TO CLEAR IT!")
	
	rp.show_page(5)
	assert_eq(rp.text_label.text, "YOU CANNOT PLACE AN ALIEN\nON A ROCK.")
	
	assert_null(rp.sound)
	
	rp.show_page(0)
	rp.next_page()
	assert_eq(rp.page_index, 1)

## CHECK: 2
func test_cr_1151_title_screen_sound_integration() -> void:
	var ts = TitleScreen.new()
	ts.settings_path = "user://test_cr_1151_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	
	ts.select_language("ja")
	ts._start_btn_tutorial.pressed.emit()
	await wait_frames(1)
	
	assert_eq(ts.rules_pages.sound, ts.sound)
	
	var n = ts.sound.played.size()
	ts.rules_pages.next_page()
	assert_eq(ts.sound.played.size(), n + 1)
	assert_eq(ts.sound.played[ts.sound.played.size() - 1], "button")
	
	ts.rules_pages.prev_page()
	assert_eq(ts.sound.played.size(), n + 2)
	assert_eq(ts.rules_pages.page_index, 0)
	
	ts.rules_pages.prev_page()
	assert_eq(ts.sound.played.size(), n + 2)
