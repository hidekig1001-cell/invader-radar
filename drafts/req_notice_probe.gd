extends GutTest
# 「盤が大きくなる面のお知らせ」案 A の確かめる項目を GUT にした見本（req_notice.txt の項目 1〜5 と同じ順）。

const EN_TEXT := "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"


func _bubble():
	var B = load("res://scenes/message_bubble.gd")
	var b = B.new()
	add_child_autofree(b)
	return b


## CHECK: 1
func test_show_size_up_style() -> void:
	var B = load("res://scenes/message_bubble.gd")
	var b = _bubble()
	b.show_size_up(EN_TEXT, Vector2(540, 980))
	assert_true(b.size_up_mode)
	assert_true(b.tile_mode)
	assert_eq(b.text, EN_TEXT)
	var sb = b.get_theme_stylebox("normal")
	assert_eq(sb.bg_color, Color8(255, 215, 64))
	assert_eq(sb.border_color, Color8(230, 110, 20))
	assert_eq(sb.border_width_top, 8)
	assert_eq(b.get_theme_font_size("font_size"), b.fit_font_size(EN_TEXT, B.TILE_SIZE, 52, 36))
	assert_eq(b.pivot_offset, Vector2(450, 80))
	assert_almost_eq(b.pop_age, 0.0, 0.001)


## CHECK: 2
func test_size_up_pop_scale() -> void:
	var B = load("res://scenes/message_bubble.gd")
	assert_almost_eq(B.size_up_pop_scale(0.15), 1.25, 0.001)
	assert_almost_eq(B.size_up_pop_scale(0.075), 1.1768, 0.001)
	assert_almost_eq(B.size_up_pop_scale(0.0), 1.0, 0.001)
	assert_almost_eq(B.size_up_pop_scale(0.3), 1.0, 0.001)
	assert_almost_eq(B.size_up_pop_scale(-1.0), 1.0, 0.001)


## CHECK: 3
func test_step_pop() -> void:
	var b = _bubble()
	b.show_size_up(EN_TEXT, Vector2(540, 980))
	b.step_pop(0.15)
	assert_almost_eq(b.pop_age, 0.15, 0.001)
	assert_true(b.scale.is_equal_approx(Vector2(1.25, 1.25)))
	b.step_pop(0.2)
	assert_almost_eq(b.pop_age, -1.0, 0.001)
	assert_eq(b.scale, Vector2(1, 1))


## CHECK: 4
func test_clear_text_after_size_up() -> void:
	var B = load("res://scenes/message_bubble.gd")
	var b = _bubble()
	b.show_size_up(EN_TEXT, Vector2(540, 980))
	b.step_pop(0.1)
	b.clear_text()
	assert_false(b.size_up_mode)
	assert_false(b.tile_mode)
	assert_almost_eq(b.pop_age, -1.0, 0.001)
	assert_eq(b.scale, Vector2(1, 1))
	assert_eq(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_font_size("font_size"), B.FONT_SIZE)


## CHECK: 5
func test_main_size_up_notice() -> void:
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var m = load("res://scenes/main.tscn").instantiate()
	m.session = SessionScript.new([l1, l2, l3])
	add_child_autofree(m)
	await wait_frames(2)
	m.session.solve_now()
	assert_true(m.bubble.tile_mode)
	assert_false(m.bubble.size_up_mode)
	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	assert_eq(m.session.level_index, 1)
	assert_eq(m.sound.played.count("line"), 0)
	m.tick_size_up(0.7)
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.text, m.size_up_tile_text())
	assert_eq(m.bubble.get_theme_stylebox("normal").bg_color, Color8(255, 215, 64))
	assert_eq(m.sound.played.count("line"), 1)
	assert_eq(m.sound.vibrations[-1], 60)
	assert_almost_eq(m.sound.vibration_amplitudes[-1], 0.6, 0.001)
