extends GutTest

const SpaceBg = preload("res://scenes/space_bg.gd")
const MainScene = preload("res://scenes/main.tscn")


func test_sky_colors() -> void:
	## CHECK: 1
	var b = autofree(SpaceBg.new())
	var colors = b.sky_colors()
	assert_eq(colors.size(), 2)
	assert_true(colors[0].is_equal_approx(Color(0.22, 0.14, 0.40)))
	assert_true(colors[1].is_equal_approx(Color(0.08, 0.10, 0.24)))


func test_star_list_properties() -> void:
	## CHECK: 2
	var b = autofree(SpaceBg.new())
	var stars = b.star_list(20261011, 60)
	assert_eq(stars.size(), 60)
	for s in stars:
		assert_true(s["pos"].x >= 0.0 and s["pos"].x <= 1080.0)
		assert_true(s["pos"].y >= 0.0 and s["pos"].y <= 1920.0)
		assert_true(s["size"] >= 3 and s["size"] <= 7)
	assert_true(stars[0]["color"].is_equal_approx(Color(1, 1, 1)))
	assert_true(stars[1]["color"].is_equal_approx(Color(1.0, 0.80, 0.90)))
	assert_true(stars[2]["color"].is_equal_approx(Color(1.0, 0.95, 0.70)))
	assert_true(stars[3]["color"].is_equal_approx(Color(0.75, 0.95, 1.0)))
	assert_true(stars[4]["color"].is_equal_approx(Color(1, 1, 1)))


func test_star_list_determinism_and_seed() -> void:
	## CHECK: 3
	var b = autofree(SpaceBg.new())
	var stars1 = b.star_list(20261011, 60)
	var stars2 = b.star_list(20261011, 60)
	assert_eq(stars1.size(), 60)
	assert_eq(stars2.size(), 60)
	for i in range(60):
		assert_true(stars1[i]["pos"].is_equal_approx(stars2[i]["pos"]))
	var stars3 = b.star_list(7, 60)
	assert_false(stars1[0]["pos"].is_equal_approx(stars3[0]["pos"]))


func test_planet_list() -> void:
	## CHECK: 4
	var b = autofree(SpaceBg.new())
	var planets = b.planet_list()
	assert_eq(planets.size(), 3)
	
	# 1. Check new position and radius for the first planet
	assert_true(planets[0]["pos"].is_equal_approx(Vector2(120, 1620)))
	assert_almost_eq(planets[0]["radius"], 80.0, 0.0001)
	assert_true(planets[0]["color"].is_equal_approx(Color(1.0, 0.70, 0.80)))
	
	# Check other planets remain unchanged
	assert_true(planets[1]["pos"].is_equal_approx(Vector2(110, 1840)))
	assert_almost_eq(planets[1]["radius"], 50.0, 0.0001)
	assert_true(planets[1]["color"].is_equal_approx(Color(1.0, 0.90, 0.50)))
	assert_true(planets[2]["pos"].is_equal_approx(Vector2(60, 60)))
	assert_almost_eq(planets[2]["radius"], 26.0, 0.0001)
	assert_true(planets[2]["color"].is_equal_approx(Color(0.60, 0.95, 0.80)))
	
	# Helper to check circle-rect intersection (distance from center to closest point on rect > radius)
	var p0_pos = planets[0]["pos"]
	var p0_radius = planets[0]["radius"]
	
	# 2. Check no overlap with rules_label Rect2(54, 1730, 972, 140)
	var rules_rect = Rect2(54, 1730, 972, 140)
	var closest_x = clamp(p0_pos.x, rules_rect.position.x, rules_rect.end.x)
	var closest_y = clamp(p0_pos.y, rules_rect.position.y, rules_rect.end.y)
	var dist_to_rules = p0_pos.distance_to(Vector2(closest_x, closest_y))
	assert_true(dist_to_rules > p0_radius)
	
	# 3. Check no overlap with board AREA Rect2(40, 480, 1000, 1000)
	var area_rect = Rect2(40, 480, 1000, 1000)
	closest_x = clamp(p0_pos.x, area_rect.position.x, area_rect.end.x)
	closest_y = clamp(p0_pos.y, area_rect.position.y, area_rect.end.y)
	var dist_to_area = p0_pos.distance_to(Vector2(closest_x, closest_y))
	assert_true(dist_to_area > p0_radius)
	
	# 4. Check no overlap with HINT button Rect2(240, 1560, 600, 150)
	var hint_rect = Rect2(240, 1560, 600, 150)
	closest_x = clamp(p0_pos.x, hint_rect.position.x, hint_rect.end.x)
	closest_y = clamp(p0_pos.y, hint_rect.position.y, hint_rect.end.y)
	var dist_to_hint = p0_pos.distance_to(Vector2(closest_x, closest_y))
	assert_true(dist_to_hint > p0_radius)
	
	# 5. Check no overlap with planet_list()[1] (center Vector2(110, 1840), radius 50)
	var p1_pos = planets[1]["pos"]
	var p1_radius = planets[1]["radius"]
	var dist_between_planets = p0_pos.distance_to(p1_pos)
	assert_true(dist_between_planets > (p0_radius + p1_radius))
	
	# 6. Check planet is within screen bounds Rect2(0, 0, 1080, 1920)
	var screen_rect = Rect2(0, 0, 1080, 1920)
	assert_true(screen_rect.encloses(Rect2(p0_pos.x - p0_radius, p0_pos.y - p0_radius, p0_radius * 2, p0_radius * 2)))


func test_main_scene_has_space_bg() -> void:
	## CHECK: 5
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	assert_not_null(m.space_bg)
	assert_eq(m.get_child(0), m.space_bg)
