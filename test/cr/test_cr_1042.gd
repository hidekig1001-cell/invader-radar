extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SpaceBgScript = preload("res://scenes/space_bg.gd")

func _start_main(size: Vector2):
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	m.apply_screen_layout(size)
	return m

## CHECK: 1
func test_pink_draw_extent_values() -> void:
	assert_almost_eq(SpaceBgScript.pink_draw_extent(80.0), 130.0, 0.001)
	assert_almost_eq(SpaceBgScript.pink_draw_extent(40.0), 65.0, 0.001)
	assert_almost_eq(SpaceBgScript.pink_draw_extent(5.0), 8.125, 0.001)

## CHECK: 2
func test_pink_scale_values() -> void:
	var s80 = SpaceBgScript.pink_scale(80.0)
	assert_almost_eq(s80, 1.0, 0.001)
	assert_true(s80 > 0.0)
	
	var s160 = SpaceBgScript.pink_scale(160.0)
	assert_almost_eq(s160, 2.0, 0.001)
	assert_true(s160 > 0.0)
	
	var s40 = SpaceBgScript.pink_scale(40.0)
	assert_almost_eq(s40, 0.5, 0.001)
	assert_true(s40 > 0.0)
	
	var s5 = SpaceBgScript.pink_scale(5.0)
	assert_almost_eq(s5, 0.0625, 0.001)
	assert_true(s5 > 0.0)

## CHECK: 3
func test_pink_ring_size_values() -> void:
	var r80 = SpaceBgScript.pink_ring_size(80.0)
	assert_true(r80.is_equal_approx(Vector2(130.0, 30.0)))
	
	var r40 = SpaceBgScript.pink_ring_size(40.0)
	assert_true(r40.is_equal_approx(Vector2(65.0, 15.0)))
	
	var r5 = SpaceBgScript.pink_ring_size(5.0)
	assert_true(r5.is_equal_approx(Vector2(8.125, 1.875)))

## CHECK: 4
func test_pink_placement_1080x2424() -> void:
	var m = await _start_main(Vector2(1080, 2424))
	var placement = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	assert_false(placement.is_empty())
	assert_true(placement.has("pos"))
	assert_true(placement.has("radius"))
	assert_true(placement["pos"].is_equal_approx(Vector2(140, 125)))
	assert_almost_eq(placement["radius"], 75.0, 0.001)

## CHECK: 5
func test_pink_placement_bounds_and_avoidance() -> void:
	var m = await _start_main(Vector2(1080, 2424))
	var placement = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	var pos = placement["pos"]
	var radius = placement["radius"]
	
	# Check extent calculation matches CR: e = radius * 130 / 80
	var e = radius * 130.0 / 80.0
	var check_rect = Rect2(pos.x - e, pos.y - e, 2 * e, 2 * e)
	var sky_rect = Rect2(Vector2.ZERO, Vector2(1080, 2424))
	
	assert_true(sky_rect.encloses(check_rect))
	
	for r in m.space_bg.avoid_rects:
		assert_false(check_rect.intersects(r))
		
	# Check against yellow and green planets (hardcoded from CR description for this specific layout)
	# Yellow: pos(110, 2298), radius 50
	# Green: pos(60, 60), radius 26
	var yellow_pos = Vector2(110, 2298)
	var yellow_radius = 50.0
	var green_pos = Vector2(60, 60)
	var green_radius = 26.0
	
	assert_true(pos.distance_to(yellow_pos) > radius + yellow_radius)
	assert_true(pos.distance_to(green_pos) > radius + green_radius)

## CHECK: 6
func test_guard_planets_and_pink_no_overlap() -> void:
	var m = await _start_main(Vector2(1080, 2424))
	var guards = m.space_bg.guard_planets()
	assert_eq(guards.size(), 2)
	
	# Identify yellow and green from guard_planets output
	var yellow_data = null
	var green_data = null
	for g in guards:
		if g["radius"] == 50.0:
			yellow_data = g
		elif g["radius"] == 26.0:
			green_data = g
			
	assert_not_null(yellow_data)
	assert_not_null(green_data)
	
	# Verify yellow and green don't overlap each other (distance > sum of radii)
	var dist_yg = yellow_data["pos"].distance_to(green_data["pos"])
	assert_true(dist_yg > 50.0 + 26.0)
	
	# Verify pink placement doesn't overlap with them
	var placement = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	var p_pos = placement["pos"]
	var p_radius = placement["radius"]
	
	assert_true(p_pos.distance_to(yellow_data["pos"]) > p_radius + yellow_data["radius"])
	assert_true(p_pos.distance_to(green_data["pos"]) > p_radius + green_data["radius"])

## CHECK: 7
func test_pink_spot_ok_logic() -> void:
	var m = await _start_main(Vector2(1080, 2424))
	# True case: pos(140, 125), radius 75.0
	assert_true(m.space_bg.pink_spot_ok(Vector2(140, 125), 75.0, m.space_bg.avoid_rects))
	
	# False case: pos(140, 125), radius 80.0 -> extent = 130. y - e = 125 - 130 = -5 < 0 (out of bounds)
	assert_false(m.space_bg.pink_spot_ok(Vector2(140, 125), 80.0, m.space_bg.avoid_rects))

## CHECK: 8
func test_planet_positions_pink_and_others_1080x2424() -> void:
	var m = await _start_main(Vector2(1080, 2424))
	var planets = m.space_bg.planet_positions(m.space_bg.avoid_rects)
	
	var pink_color = Color(1.0, 0.70, 0.80)
	var yellow_color = Color(1.0, 0.90, 0.50)
	var green_color = Color(0.60, 0.95, 0.80)
	
	var pink_planet = null
	var yellow_planet = null
	var green_planet = null
	
	for p in planets:
		if p["color"] == pink_color:
			pink_planet = p
		elif p["color"] == yellow_color:
			yellow_planet = p
		elif p["color"] == green_color:
			green_planet = p
			
	assert_not_null(pink_planet)
	assert_not_null(yellow_planet)
	assert_not_null(green_planet)
	
	# Pink should match placement
	var placement = m.space_bg.pink_placement(m.space_bg.avoid_rects)
	assert_true(pink_planet["pos"].is_equal_approx(placement["pos"]))
	assert_almost_eq(pink_planet["radius"], placement["radius"], 0.001)
	
	# Yellow and Green specific values from CR
	assert_true(yellow_planet["pos"].is_equal_approx(Vector2(110, 2298)))
	assert_almost_eq(yellow_planet["radius"], 50.0, 0.001)
	
	assert_true(green_planet["pos"].is_equal_approx(Vector2(60, 60)))
	assert_almost_eq(green_planet["radius"], 26.0, 0.001)

## CHECK: 9
func test_pink_placement_empty_1080x1920_and_present_1080x2424() -> void:
	# Case 1: 1080x1920 -> Pink should be empty
	var m1 = await _start_main(Vector2(1080, 1920))
	var placement1 = m1.space_bg.pink_placement(m1.space_bg.avoid_rects)
	assert_true(placement1.is_empty())
	
	var planets1 = m1.space_bg.planet_positions(m1.space_bg.avoid_rects)
	var has_pink1 = false
	for p in planets1:
		if p["color"] == Color(1.0, 0.70, 0.80):
			has_pink1 = true
	assert_false(has_pink1)
	
	# Case 2: 1080x2424 -> Pink should be present with specific values
	var m2 = await _start_main(Vector2(1080, 2424))
	var placement2 = m2.space_bg.pink_placement(m2.space_bg.avoid_rects)
	assert_false(placement2.is_empty())
	assert_true(placement2["pos"].is_equal_approx(Vector2(140, 125)))
	assert_almost_eq(placement2["radius"], 75.0, 0.001)
	
	var planets2 = m2.space_bg.planet_positions(m2.space_bg.avoid_rects)
	var pink_planet2 = null
	var yellow_planet2 = null
	var green_planet2 = null
	
	for p in planets2:
		if p["color"] == Color(1.0, 0.70, 0.80):
			pink_planet2 = p
		elif p["color"] == Color(1.0, 0.90, 0.50):
			yellow_planet2 = p
		elif p["color"] == Color(0.60, 0.95, 0.80):
			green_planet2 = p
			
	assert_not_null(pink_planet2)
	assert_true(pink_planet2["pos"].is_equal_approx(Vector2(140, 125)))
	assert_almost_eq(pink_planet2["radius"], 75.0, 0.001)
	
	assert_not_null(yellow_planet2)
	assert_true(yellow_planet2["pos"].is_equal_approx(Vector2(110, 2298)))
	assert_almost_eq(yellow_planet2["radius"], 50.0, 0.001)
	
	assert_not_null(green_planet2)
	assert_true(green_planet2["pos"].is_equal_approx(Vector2(60, 60)))
	assert_almost_eq(green_planet2["radius"], 26.0, 0.001)
