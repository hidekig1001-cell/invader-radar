extends GutTest

const MessageBubbleScript = preload("res://scenes/message_bubble.gd")
const MainScene = preload("res://scenes/main.tscn")


func test_show_tile_and_clear_text() -> void:
	## CHECK: 1
	var b = MessageBubbleScript.new()
	add_child_autofree(b)
	await wait_frames(1)

	assert_eq(b.position, Vector2(90, 340))

	b.show_tile("CLEAR", Vector2(540, 900))
	assert_true(b.visible)
	assert_eq(b.text, "CLEAR")
	assert_true(b.tile_mode)
	assert_eq(b.position, Vector2(90, 1020))
	assert_eq(b.size, Vector2(900, 160))
	assert_true(b.get_theme_stylebox("normal") is StyleBoxFlat)

	b.show_tile("CLEAR", Vector2(540, 800))
	assert_eq(b.position, Vector2(90, 920))

	b.clear_text()
	assert_false(b.visible)
	assert_false(b.tile_mode)
	assert_eq(b.position, Vector2(90, 340))
	assert_eq(b.size, Vector2(900, 120))
	assert_true(b.get_theme_stylebox("normal") is StyleBoxFlat)


func test_main_integration_tile() -> void:
	## CHECK: 2
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	var p0 = m.bubble.position

	m.session.solve_now()
	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, m.cleared_text())
	var expected_pos = m.board_view.position + m.board_view.board_rect().get_center() + Vector2(-450, 120)
	assert_true(m.bubble.position.is_equal_approx(expected_pos))

	m.session.next_level()
	assert_false(m.bubble.tile_mode)
	assert_false(m.bubble.visible)
	assert_eq(m.bubble.position, p0)
