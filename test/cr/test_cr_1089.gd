extends GutTest

const Hud = preload("res://scenes/hud.gd")


func _start():
	var hud = Hud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	return hud


## CHECK: 1
func test_cr_1089_table_box_is_styleboxflat_with_corner_radius() -> void:
	var hud = await _start()
	var bx = hud.table_box()
	assert_true(bx is StyleBoxFlat)
	assert_eq(bx.corner_radius_top_left, 24)
	assert_eq(bx.corner_radius_top_right, 24)
	assert_eq(bx.corner_radius_bottom_left, 24)
	assert_eq(bx.corner_radius_bottom_right, 24)


## CHECK: 2
func test_cr_1089_table_box_colors_and_border_widths() -> void:
	var hud = await _start()
	var bx = hud.table_box()
	assert_true(bx.bg_color.is_equal_approx(Hud.TABLE_BG))
	assert_true(bx.border_color.is_equal_approx(Hud.TABLE_LINE))
	assert_eq(bx.border_width_left, 3)
	assert_eq(bx.border_width_top, 3)
	assert_eq(bx.border_width_right, 3)
	assert_eq(bx.border_width_bottom, 3)
