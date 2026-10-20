extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_title_logo_layout_and_collision() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	var lg = m.title_logo
	assert_not_null(lg)
	assert_true(lg.visible)
	assert_eq(lg.size, Vector2(760, 152))
	assert_almost_eq(lg.position.x + lg.size.x, m.hud.position.x + 1040.0, 0.01)
	
	var pk = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	assert_false(pk.is_empty())
	var e = m.space_bg.pink_draw_extent(pk["radius"])
	var logo_rect = Rect2(lg.position, lg.size)
	var planet_rect = Rect2(pk["pos"].x - e, pk["pos"].y - e, 2 * e, 2 * e)
	assert_false(logo_rect.intersects(planet_rect))
	
	assert_true(lg.position.y >= 0.0)
	assert_true(lg.position.y + lg.size.y <= m.hud.position.y + 90.0 - 10.0)
	
	var rects = m.part_rects()
	assert_true(rects.has(Rect2(lg.position, lg.size)))
	
	m.apply_screen_layout(Vector2(1080, 1920))
	assert_false(m.title_logo.visible)


## CHECK: 2
func test_title_logo_texture_and_filter() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	var lg = m.title_logo
	assert_not_null(lg)
	assert_not_null(lg.texture)
	assert_eq(lg.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST)
	assert_eq(lg.mouse_filter, Control.MOUSE_FILTER_IGNORE)
