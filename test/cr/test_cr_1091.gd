extends GutTest

const Bubble = preload("res://scenes/message_bubble.gd")


func _make_bubble():
	var b = Bubble.new()
	add_child_autofree(b)
	await wait_frames(1)
	return b


## CHECK: 1
func test_cr_1091_panel_alpha_values() -> void:
	var b = await _make_bubble()
	assert_almost_eq(b.panel_alpha(0.0), 1.0, 0.001)
	assert_almost_eq(b.panel_alpha(0.8), 0.55, 0.001)
	assert_almost_eq(b.panel_alpha(1.6), 1.0, 0.001)


## CHECK: 2
func test_cr_1091_step_blink_panel_mode() -> void:
	var b = await _make_bubble()
	b.show_panel("A")
	b.blink_time = 0.0
	b.step_blink(0.8)
	assert_almost_eq(b.modulate.a, 0.55, 0.001)
	b.step_blink(0.8)
	assert_almost_eq(b.modulate.a, 1.0, 0.001)
	b.step_blink(0.8)
	b.clear_text()
	assert_almost_eq(b.modulate.a, 1.0, 0.001)
	assert_eq(b.blink_time, 0.0)


## CHECK: 3
func test_cr_1091_step_blink_non_panel_mode() -> void:
	var b = await _make_bubble()
	b.show_text("A", 0.0)
	b.modulate.a = 0.5
	b.step_blink(0.8)
	assert_almost_eq(b.modulate.a, 1.0, 0.001)
	b.show_tile("B", Vector2(540, 900))
	b.modulate.a = 0.5
	b.step_blink(0.8)
	assert_almost_eq(b.modulate.a, 1.0, 0.001)
