extends GutTest

const RulesLabelScript = preload("res://scenes/rules_label.gd")
const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_make_style_box_texture() -> void:
	var sb = RulesLabelScript.make_style_box()
	assert_true(sb is StyleBoxTexture, "make_style_box should return StyleBoxTexture")
	var tex = sb.texture
	assert_not_null(tex, "StyleBoxTexture should have a texture")
	assert_eq(tex.resource_path, "res://assets/buttons/button_normal.png")
	assert_eq(tex.get_width(), 360)
	assert_eq(tex.get_height(), 140)


## CHECK: 2
func test_make_style_box_texture_margins() -> void:
	var sb = RulesLabelScript.make_style_box()
	assert_eq(sb.texture_margin_left, 32.0)
	assert_eq(sb.texture_margin_right, 32.0)
	assert_eq(sb.texture_margin_top, 44.0)
	assert_eq(sb.texture_margin_bottom, 40.0)


## CHECK: 3
func test_make_style_box_content_margins() -> void:
	var sb = RulesLabelScript.make_style_box()
	assert_eq(sb.content_margin_left, 32.0)
	assert_eq(sb.content_margin_right, 32.0)
	assert_eq(sb.content_margin_top, 16.0)
	assert_eq(sb.content_margin_bottom, 16.0)


## CHECK: 4
func test_rules_label_stylebox_applied() -> void:
	var m = await _start()
	var sb = RulesLabelScript.make_style_box()
	var applied_sb = m.rules_label.get_theme_stylebox("normal")
	assert_true(applied_sb is StyleBoxTexture, "rules_label should have a StyleBoxTexture stylebox")
	assert_eq(applied_sb.texture.resource_path, "res://assets/buttons/button_normal.png")
	assert_eq(applied_sb.texture_margin_top, 44.0)
	assert_eq(applied_sb.content_margin_top, 16.0)


## CHECK: 5
func test_rules_label_font_color() -> void:
	var m = await _start()
	var expected_color = RulesLabelScript.text_color()
	var actual_color = m.rules_label.get_theme_color("font_color")
	assert_true(actual_color.is_equal_approx(expected_color), "Font color should match text_color()")
	assert_true(expected_color.is_equal_approx(Color("#4A320A")), "text_color() should return #4A320A")


## CHECK: 6
func test_rules_label_z_index() -> void:
	var m = await _start()
	assert_eq(m.rules_label.z_index, 10)
	assert_true(m.rules_label.z_index > m.space_bg.z_index, "rules_label z_index should be greater than space_bg z_index")
