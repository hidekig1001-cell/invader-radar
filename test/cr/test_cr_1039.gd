extends GutTest

const SpaceBg = preload("res://scenes/space_bg.gd")
const MainScene = preload("res://scenes/main.tscn")
const TitleScreenScript = preload("res://scenes/title_screen.gd")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _start_title():
	var t = TitleScreenScript.new()
	add_child_autofree(t)
	await wait_frames(2)
	return t


## CHECK: 1
func test_layout_offsets_values() -> void:
	assert_eq(SpaceBg.layout_offsets(1080, 1920), Vector2(0, 0))
	assert_eq(SpaceBg.layout_offsets(1080, 2424), Vector2(0, 252))
	assert_eq(SpaceBg.layout_offsets(1080, 2520), Vector2(0, 300))
	assert_eq(SpaceBg.layout_offsets(1440, 1920), Vector2(180, 0))


## CHECK: 2
func test_screen_size_for_layout_values() -> void:
	assert_eq(SpaceBg.screen_size_for_layout(Vector2(1920, 1920), "headless"), Vector2(1080, 1920))
	assert_eq(SpaceBg.screen_size_for_layout(Vector2(1080, 2424), "en"), Vector2(1080, 2424))


## CHECK: 3
func test_main_apply_screen_layout_vertical() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1080, 2424))
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(m.rules_label.position, Vector2(54, 1982))
	assert_eq(m.hud.hint_button.get_global_rect(), Rect2(250, 1812, 380, 150))


## CHECK: 4
func test_main_apply_screen_layout_sky_and_avoid() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(m.space_bg.sky_size, Vector2(1080, 2424))
	assert_true(m.space_bg.avoid_rects.has(Rect2(54, 1982, 972, 140)))
	assert_true(m.space_bg.avoid_rects.has(Rect2(40, 732, 1000, 1000)))


## CHECK: 5
func test_main_planet_positions_pink() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1080, 2424))
	var planets = m.space_bg.planet_positions(m.space_bg.avoid_rects)
	var pink_planets = []
	for p in planets:
		if p["color"] == Color(1.0, 0.70, 0.80):
			pink_planets.append(p)
	assert_true(pink_planets.size() > 0)
	for p in pink_planets:
		var pos = p["pos"]
		var radius = p["radius"]
		assert_true(pos.is_equal_approx(Vector2(130, 170)))
		assert_almost_eq(radius, 80.0, 0.001)
		var e = SpaceBg.pink_draw_extent(radius)
		var draw_rect = Rect2(pos.x - e, pos.y - e, 2 * e, 2 * e)
		for rect in m.space_bg.avoid_rects:
			assert_false(draw_rect.intersects(rect))


## CHECK: 6
func test_main_planet_positions_yellow() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1080, 2424))
	var planets = m.space_bg.planet_positions(m.space_bg.avoid_rects)
	var yellow_planets = []
	for p in planets:
		if p["color"] == Color(1.0, 0.90, 0.50):
			yellow_planets.append(p)
	assert_true(yellow_planets.size() > 0)
	for p in yellow_planets:
		var pos = p["pos"]
		var radius = p["radius"]
		assert_true(pos.y - radius >= 2122)
		assert_true(pos.y + radius <= 2424)
		for rect in m.space_bg.avoid_rects:
			var circle_rect = Rect2(pos.x - radius, pos.y - radius, radius * 2, radius * 2)
			assert_false(circle_rect.intersects(rect))


## CHECK: 7
func test_title_apply_screen_layout_vertical() -> void:
	var t = await _start_title()
	t.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(t.background.size, Vector2(1080, 2052))
	assert_eq(t._title_label.position, Vector2(0, 732))
	assert_eq(t._lang_btn_en.position, Vector2(150, 1132))


## CHECK: 8
func test_title_apply_screen_layout_horizontal() -> void:
	var t = await _start_title()
	t.apply_screen_layout(Vector2(1440, 1920))
	t.apply_screen_layout(Vector2(1440, 1920))
	assert_eq(t._lang_btn_en.position, Vector2(330, 880))
	assert_eq(t._start_btn_now.position, Vector2(330, 1400))


## CHECK: 9
func test_main_apply_screen_layout_horizontal() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1440, 1920))
	assert_eq(m.rules_label.position, Vector2(234, 1730))
	assert_eq(m.hud.undo_button.get_global_rect(), Rect2(220, 260, 320, 100))
