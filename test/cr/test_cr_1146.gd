extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const MessageBubbleScript = preload("res://scenes/message_bubble.gd")


## CHECK: 1
func test_cr_1146_main_scene_bubble_geometry_and_no_overlap() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	assert_eq(m.bubble.position, Vector2(40, 262))
	assert_eq(m.bubble.size, Vector2(1000, 192))

	var b := Rect2(m.bubble.position, m.bubble.size)
	assert_false(b.intersects(m.hud.TABLE_RECT), "Bubble should not intersect HUD table")
	assert_false(b.intersects(m.board_view.board_bg_rect()), "Bubble should not intersect board background")
	assert_false(b.intersects(Rect2(m.hud.undo_button.position, m.hud.undo_button.size)), "Bubble should not intersect undo button")


## CHECK: 2
func test_cr_1146_message_bubble_constants_and_panel_geometry() -> void:
	var bb = MessageBubbleScript.new()
	add_child_autofree(bb)
	await wait_frames(1)

	assert_eq(bb.BOX, Rect2(40, 262, 1000, 192))
	assert_eq(bb.PANEL_BOX, Rect2(40, 262, 1000, 192))

	bb.show_panel("STEP")
	assert_eq(bb.position, Vector2(40, 262))
	assert_eq(bb.size, Vector2(1000, 192))

	bb.clear_text()
	assert_eq(bb.position, Vector2(40, 262))
	assert_eq(bb.size, Vector2(1000, 192))
