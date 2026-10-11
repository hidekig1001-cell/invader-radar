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
	assert_true(planets[0]["pos"].is_equal_approx(Vector2(950, 1840)))
	assert_almost_eq(planets[0]["radius"], 80.0, 0.0001)
	assert_true(planets[0]["color"].is_equal_approx(Color(1.0, 0.70, 0.80)))
	assert_true(planets[1]["pos"].is_equal_approx(Vector2(110, 1840)))
	assert_almost_eq(planets[1]["radius"], 50.0, 0.0001)
	assert_true(planets[1]["color"].is_equal_approx(Color(1.0, 0.90, 0.50)))
	assert_true(planets[2]["pos"].is_equal_approx(Vector2(60, 60)))
	assert_almost_eq(planets[2]["radius"], 26.0, 0.0001)
	assert_true(planets[2]["color"].is_equal_approx(Color(0.60, 0.95, 0.80)))


func test_main_scene_has_space_bg() -> void:
	## CHECK: 5
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	assert_not_null(m.space_bg)
	assert_eq(m.get_child(0), m.space_bg)
