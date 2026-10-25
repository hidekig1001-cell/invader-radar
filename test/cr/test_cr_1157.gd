extends GutTest

## CHECK: 1
func test_cr_1157_table_colors_constants() -> void:
	var Hud = load("res://scenes/hud.gd")
	assert_eq(Hud.TABLE_BG, Color8(60, 45, 120))
	assert_eq(Hud.TABLE_LINE, Color8(140, 120, 210))
	assert_eq(Hud.TABLE_TEXT, Color8(245, 240, 255))

## CHECK: 2
func test_cr_1157_table_box_colors_instantiated() -> void:
	var MS = load("res://scenes/main.tscn")
	var m = MS.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	var bx = m.hud.table_box()
	assert_eq(bx.bg_color, Color8(60, 45, 120))
	assert_eq(bx.border_color, Color8(140, 120, 210))
