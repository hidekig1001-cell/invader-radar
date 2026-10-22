extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SpaceBgScript = preload("res://scenes/space_bg.gd")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1133_logo_and_pink_placement_tall_screen() -> void:
	var m = await _start_main()
	m.apply_screen_layout(Vector2(1080, 2424))
	
	var lg = m.title_logo
	assert_true(lg.visible)
	
	# Check logo position relative to HUD and LOGO_GAP
	# Expected y: hud.position.y + 90.0 - 20.0 - lg.size.y
	# So lg.position.y + lg.size.y == hud.position.y + 70.0
	var expected_bottom_y = m.hud.position.y + 90.0 - 20.0
	assert_almost_eq(lg.position.y + lg.size.y, expected_bottom_y, 0.1)
	
	# Check pink_min_y is set to logo's top y
	assert_almost_eq(m.space_bg.pink_min_y, lg.position.y, 0.1)
	
	# Check pink placement respects pink_min_y and avoids logo
	var pk = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	assert_false(pk.is_empty())
	
	# Pink pos y should be >= logo top y (since pink_min_y is logo top y)
	assert_true(pk["pos"].y >= lg.position.y)
	
	# Check that the drawn extent of the pink planet does not intersect the logo
	var e = m.space_bg.pink_draw_extent(pk["radius"])
	var pink_rect = Rect2(pk["pos"].x - e, pk["pos"].y - e, 2 * e, 2 * e)
	var logo_rect = Rect2(lg.position, lg.size)
	assert_false(pink_rect.intersects(logo_rect))


## CHECK: 2
func test_cr_1133_logo_hidden_short_screen() -> void:
	var m = await _start_main()
	
	# Force a state that would be incorrect if the implementation is missing or wrong.
	# If place_title_logo does not set pink_min_y to 0.0 when hiding, this will fail.
	m.space_bg.pink_min_y = 100.0
	
	m.apply_screen_layout(Vector2(1080, 1920))
	
	var lg = m.title_logo
	assert_false(lg.visible)
	assert_almost_eq(m.space_bg.pink_min_y, 0.0, 0.1)
