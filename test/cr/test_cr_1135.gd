extends GutTest

const BubbleScript = preload("res://scenes/message_bubble.gd")
const MainScene = preload("res://scenes/main.tscn")


## CHECK: 1
func test_cr_1135_bubble_geometry_and_font() -> void:
	var b = BubbleScript.new()
	add_child_autofree(b)
	assert_eq(b.position, Vector2(40, 340))
	assert_eq(b.size, Vector2(660, 120))
	assert_eq(b.get_theme_font_size("font_size"), 36)

	b.show_panel("STEP")
	assert_eq(b.position, Vector2(40, 366))
	assert_eq(b.size, Vector2(660, 108))
	assert_eq(b.get_theme_font_size("font_size"), 48)

	b.clear_text()
	assert_eq(b.position, Vector2(40, 340))
	assert_eq(b.size, Vector2(660, 120))
	assert_eq(b.get_theme_font_size("font_size"), 36)


## CHECK: 2
func test_cr_1135_bubble_does_not_overlap_sound_button() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	m.hud.hint_button.pressed.emit()
	await wait_frames(1)

	assert_true(m.bubble.visible)
	var bubble_rect := Rect2(m.bubble.position, m.bubble.size)
	var sound_rect := Rect2(m.hud.position + m.hud.sound_button.position, m.hud.sound_button.size)
	assert_false(bubble_rect.intersects(sound_rect))

	m.apply_screen_layout(Vector2(1080, 2424))
	await wait_frames(1)

	bubble_rect = Rect2(m.bubble.position, m.bubble.size)
	sound_rect = Rect2(m.hud.position + m.hud.sound_button.position, m.hud.sound_button.size)
	assert_false(bubble_rect.intersects(sound_rect))
