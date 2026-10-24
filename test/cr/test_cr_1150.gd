extends GutTest

## CHECK: 1
func test_cr_1150_rules_pages_basic() -> void:
	var RP = load("res://scenes/rules_pages.gd")
	var rp = RP.new()
	rp.language = "ja"
	add_child_autofree(rp)
	await wait_frames(1)

	assert_eq(rp.page_count(), 7)
	assert_eq(rp.page_index, 0)
	assert_eq(rp.image.texture.resource_path, "res://assets/rules/rules_1.png")
	assert_eq(rp.text_label.text, "盤のマスに宇宙人の駒を置こう。\nルールを全部守るとクリア！")
	assert_eq(rp.page_label.text, "1 / 7")
	assert_true(rp.back_btn.disabled)
	assert_eq(rp.next_btn.text, "つぎへ")

	assert_false(Rect2(rp.text_label.position, rp.text_label.size).intersects(Rect2(rp.image.position, rp.image.size)))
	assert_false(Rect2(rp.image.position, rp.image.size).intersects(Rect2(rp.page_label.position, rp.page_label.size)))
	assert_false(Rect2(rp.image.position, rp.image.size).intersects(Rect2(rp.back_btn.position, rp.back_btn.size)))
	assert_false(Rect2(rp.back_btn.position, rp.back_btn.size).intersects(Rect2(rp.next_btn.position, rp.next_btn.size)))

	rp.next_page()
	assert_eq(rp.page_index, 1)
	assert_eq(rp.image.texture.resource_path, "res://assets/rules/rules_2.png")
	assert_false(rp.back_btn.disabled)

	rp.prev_page()
	assert_eq(rp.page_index, 0)

	rp.show_page(6)
	assert_eq(rp.image.texture.resource_path, "res://assets/rules/rules_7.png")
	assert_eq(rp.text_label.text, "1 回タップで × を付ける。\n2 回タップで駒を置く。")
	assert_eq(rp.page_label.text, "7 / 7")
	assert_eq(rp.next_btn.text, "はじめる")

	watch_signals(rp)
	rp.next_page()
	assert_signal_emitted(rp, "finished")


## CHECK: 2
func test_cr_1150_title_screen_integration() -> void:
	var TS = load("res://scenes/title_screen.gd")
	var ts = TS.new()
	ts.settings_path = "user://test_cr_1150_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)

	ts.select_language("en")
	watch_signals(ts)
	ts._start_btn_tutorial.pressed.emit()
	await wait_frames(1)

	assert_not_null(ts.rules_pages)
	assert_eq(ts.rules_pages.text_label.text, "PLACE THE ALIEN PIECES ON THE BOARD.\nKEEP ALL THE RULES TO CLEAR IT!")
	assert_signal_not_emitted(ts, "start_requested")

	ts.rules_pages.finished.emit()
	await wait_frames(1)

	assert_null(ts.rules_pages)
	assert_signal_emitted_with_parameters(ts, "start_requested", [true])
