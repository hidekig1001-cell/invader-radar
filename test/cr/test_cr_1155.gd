extends GutTest

## CHECK: 1
func test_cr_1155_page_count_and_content() -> void:
	var RP = load("res://scenes/rules_pages.gd")
	var rp = RP.new()
	rp.language = "ja"
	add_child_autofree(rp)
	await wait_frames(1)
	
	assert_eq(rp.page_count(), 8)
	
	rp.show_page(7)
	assert_eq(rp.image.texture.resource_path, "res://assets/rules/rules_8.png")
	assert_eq(rp.text_label.text, "× のマスを 1 回タップで × を消す。\n宇宙人のマスを 2 回タップで取り除く。")
	assert_eq(rp.page_label.text, "8 / 8")
	
	rp.language = "en"
	rp.show_page(7)
	assert_eq(rp.text_label.text, "TAP AN X AGAIN TO ERASE IT.\nDOUBLE TAP AN ALIEN TO REMOVE IT.")

## CHECK: 2
func test_cr_1155_next_page_signals() -> void:
	var RP = load("res://scenes/rules_pages.gd")
	var rp = RP.new()
	rp.language = "ja"
	add_child_autofree(rp)
	await wait_frames(1)
	
	watch_signals(rp)
	
	rp.show_page(6)
	rp.next_page()
	assert_eq(rp.page_index, 7)
	assert_signal_not_emitted(rp, "finished")
	
	rp.next_page()
	assert_signal_emitted(rp, "finished")
