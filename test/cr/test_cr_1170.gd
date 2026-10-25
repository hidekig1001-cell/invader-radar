extends GutTest

func test_cr_1170_font_size_and_layout() -> void:
	## CHECK: 1
	var RP = load("res://scenes/rules_panel.gd")
	var p = RP.new()
	add_child_autofree(p)
	await wait_frames(1)
	
	p.open("ja")
	await wait_frames(1)
	assert_eq(p.body_label.get_theme_font_size("font_size"), 34, "Font size should be 34 for ja")
	assert_eq(p.body_label.get_line_count(), 19, "Line count should be 19 for ja")
	var min_y_ja = p.body_label.get_combined_minimum_size().y + 100
	assert_true(min_y_ja <= p.body_label.size.y, "Body label height must fit in size for ja")
	
	p.open("en")
	await wait_frames(1)
	assert_eq(p.body_label.get_theme_font_size("font_size"), 34, "Font size should be 34 for en")
	assert_eq(p.body_label.get_line_count(), 17, "Line count should be 17 for en")
	var min_y_en = p.body_label.get_combined_minimum_size().y + 100
	assert_true(min_y_en <= p.body_label.size.y, "Body label height must fit in size for en")
