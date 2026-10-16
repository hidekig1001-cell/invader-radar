extends GutTest

const SpaceBgScript = preload("res://scenes/space_bg.gd")

func _get_planet_list() -> Array:
	var bg = SpaceBgScript.new()
	return bg.planet_list()

## CHECK: 1
func test_cr_1029_planet_pos_and_radius() -> void:
	var planets = _get_planet_list()
	assert_eq(planets.size(), 3, "planet_list should have 3 planets")
	var p0 = planets[0]
	assert_eq(p0["pos"], Vector2(120, 1620), "First planet pos should be (120, 1620)")
	assert_eq(p0["radius"], 80.0, "First planet radius should be 80.0")

## CHECK: 2
func test_cr_1029_planet_not_overlap_rules_label() -> void:
	var planets = _get_planet_list()
	assert_true(planets.size() > 0, "planet_list must not be empty")
	var p0 = planets[0]
	var center: Vector2 = p0["pos"]
	var radius: float = p0["radius"]
	
	# rules_label rect: x 54~1026, y 1730~1870 -> Rect2(54, 1730, 972, 140)
	var rules_rect = Rect2(54, 1730, 972, 140)
	
	# Check if circle overlaps rect
	# Find closest point on rect to center
	var closest_x = clamp(center.x, rules_rect.position.x, rules_rect.end.x)
	var closest_y = clamp(center.y, rules_rect.position.y, rules_rect.end.y)
	var closest_point = Vector2(closest_x, closest_y)
	
	var dist_sq = center.distance_squared_to(closest_point)
	assert_true(dist_sq > radius * radius, "Planet should not overlap rules_label")

## CHECK: 3
func test_cr_1029_planet_not_overlap_board_area() -> void:
	var planets = _get_planet_list()
	assert_true(planets.size() > 0, "planet_list must not be empty")
	var p0 = planets[0]
	var center: Vector2 = p0["pos"]
	var radius: float = p0["radius"]
	
	# Verify the planet is actually at the expected position to ensure we are testing the right thing
	assert_eq(center, Vector2(120, 1620), "Planet pos must be (120, 1620) for this check")
	assert_eq(radius, 80.0, "Planet radius must be 80.0 for this check")

	# Board AREA rect: x 40~1040, y 480~1480 -> Rect2(40, 480, 1000, 1000)
	var area_rect = Rect2(40, 480, 1000, 1000)
	
	# Find closest point on rect to center
	var closest_x = clamp(center.x, area_rect.position.x, area_rect.end.x)
	var closest_y = clamp(center.y, area_rect.position.y, area_rect.end.y)
	var closest_point = Vector2(closest_x, closest_y)
	
	var dist_sq = center.distance_squared_to(closest_point)
	assert_true(dist_sq > radius * radius, "Planet should not overlap board AREA")

## CHECK: 4
func test_cr_1029_planet_not_overlap_hint_button() -> void:
	var planets = _get_planet_list()
	assert_true(planets.size() > 0, "planet_list must not be empty")
	var p0 = planets[0]
	var center: Vector2 = p0["pos"]
	var radius: float = p0["radius"]
	
	# Verify the planet is actually at the expected position to ensure we are testing the right thing
	assert_eq(center, Vector2(120, 1620), "Planet pos must be (120, 1620) for this check")
	assert_eq(radius, 80.0, "Planet radius must be 80.0 for this check")

	# HINT button rect: x 240~840, y 1560~1710 -> Rect2(240, 1560, 600, 150)
	var hint_rect = Rect2(240, 1560, 600, 150)
	
	# Find closest point on rect to center
	var closest_x = clamp(center.x, hint_rect.position.x, hint_rect.end.x)
	var closest_y = clamp(center.y, hint_rect.position.y, hint_rect.end.y)
	var closest_point = Vector2(closest_x, closest_y)
	
	var dist_sq = center.distance_squared_to(closest_point)
	assert_true(dist_sq > radius * radius, "Planet should not overlap HINT button")

## CHECK: 5
func test_cr_1029_planet_not_overlap_second_planet() -> void:
	var planets = _get_planet_list()
	assert_true(planets.size() > 1, "planet_list must have at least 2 planets")
	var p0 = planets[0]
	var p1 = planets[1]
	
	var center0: Vector2 = p0["pos"]
	var radius0: float = p0["radius"]
	var center1: Vector2 = p1["pos"]
	var radius1: float = p1["radius"]
	
	# Verify the first planet is at the expected position
	assert_eq(center0, Vector2(120, 1620), "First planet pos must be (120, 1620) for this check")
	assert_eq(radius0, 80.0, "First planet radius must be 80.0 for this check")

	var dist_sq = center0.distance_squared_to(center1)
	var min_dist = radius0 + radius1
	
	assert_true(dist_sq > min_dist * min_dist, "First planet should not overlap second planet")

## CHECK: 6
func test_cr_1029_planet_fits_screen() -> void:
	var planets = _get_planet_list()
	assert_true(planets.size() > 0, "planet_list must not be empty")
	var p0 = planets[0]
	var center: Vector2 = p0["pos"]
	var radius: float = p0["radius"]
	
	# Verify the planet is actually at the expected position to ensure we are testing the right thing
	assert_eq(center, Vector2(120, 1620), "Planet pos must be (120, 1620) for this check")
	assert_eq(radius, 80.0, "Planet radius must be 80.0 for this check")

	# Screen rect: 0,0 to 1080,1920
	var screen_rect = Rect2(0, 0, 1080, 1920)
	
	# Calculate bounding box of the planet
	var left = center.x - radius
	var right = center.x + radius
	var top = center.y - radius
	var bottom = center.y + radius
	
	assert_true(left >= screen_rect.position.x, "Planet left edge should be within screen")
	assert_true(right <= screen_rect.end.x, "Planet right edge should be within screen")
	assert_true(top >= screen_rect.position.y, "Planet top edge should be within screen")
	assert_true(bottom <= screen_rect.end.y, "Planet bottom edge should be within screen")
