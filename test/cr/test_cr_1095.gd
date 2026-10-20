extends GutTest

const Bubble = preload("res://scenes/message_bubble.gd")


## CHECK: 1
func test_cr_1095_clear_tile_box_style() -> void:
	var b = Bubble.new()
	add_child_autofree(b)
	await wait_frames(1)
	b.show_tile("B", Vector2(540, 900))
	var sb = b.get_theme_stylebox("normal")
	assert_true(sb is StyleBoxFlat)
	assert_eq(sb.bg_color, Color8(255, 205, 222))
	assert_eq(sb.border_color, Color8(232, 150, 180))
	assert_eq(sb.border_width_left, 4)
	assert_eq(sb.corner_radius_top_left, 24)
	assert_eq(b.get_theme_color("font_color"), Bubble.TILE_FONT_COLOR)
