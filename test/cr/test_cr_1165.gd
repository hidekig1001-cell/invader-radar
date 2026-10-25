extends GutTest

const RulesPages = preload("res://scenes/rules_pages.gd")

func _setup_rp(lang: String) -> Node:
	var rp = RulesPages.new()
	rp.language = lang
	add_child_autofree(rp)
	await wait_frames(1)
	return rp

## CHECK: 1
func test_cr_1165_page5_ja_text_and_layout() -> void:
	var rp = await _setup_rp("ja")
	rp.show_page(4)
	await wait_frames(1)
	
	var expected_text = "数字は、まわりの 8 マスにいる\n宇宙人の数。\n数字のマスに宇宙人はいない。"
	assert_eq(rp.text_label.text, expected_text)
	assert_eq(rp.text_label.get_line_count(), 3)
	assert_true(rp.text_label.get_combined_minimum_size().y <= rp.text_label.size.y)

## CHECK: 1
func test_cr_1165_page5_en_text_and_layout() -> void:
	var rp = await _setup_rp("en")
	rp.show_page(4)
	await wait_frames(1)
	
	var expected_text = "A NUMBER TELLS HOW MANY ALIENS\nARE IN THE 8 CELLS AROUND IT.\nNO ALIEN IS ON A NUMBER CELL."
	assert_eq(rp.text_label.text, expected_text)
	assert_eq(rp.text_label.get_line_count(), 3)
