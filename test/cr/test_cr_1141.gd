extends GutTest

const BubbleScript = preload("res://scenes/message_bubble.gd")


func test_cr_1141_normal_box_colors_and_font() -> void:
	## CHECK: 1
	var B = load("res://scenes/message_bubble.gd")
	var b = B.new()
	add_child_autofree(b)
	await wait_frames(1)
	assert_eq(b.normal_box.bg_color, Color8(255, 200, 150))
	assert_eq(b.normal_box.border_color, Color8(235, 150, 80))
	assert_eq(b.get_theme_color("font_color"), B.TILE_FONT_COLOR)
	assert_eq(b.get_theme_constant("outline_size"), 0)


func test_cr_1141_clear_text_restores_normal_style() -> void:
	## CHECK: 2
	var B = load("res://scenes/message_bubble.gd")
	var b = B.new()
	add_child_autofree(b)
	await wait_frames(1)
	b.show_tile("CLEAR", Vector2(540, 900))
	b.clear_text()
	assert_eq(b.get_theme_stylebox("normal").bg_color, Color8(255, 200, 150))
	assert_eq(b.get_theme_color("font_color"), B.TILE_FONT_COLOR)
	assert_eq(b.get_theme_constant("outline_size"), 0)
