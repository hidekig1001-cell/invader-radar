extends GutTest

const BoardView = preload("res://scenes/board_view.gd")

var v: Node2D


func before_each() -> void:
	v = BoardView.new()
	autofree(v)


## CHECK: 1
func test_cr_1023_point_count() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	assert_eq(p.size(), 20)


## CHECK: 2
func test_cr_1023_top_left_corner() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	assert_true(p[0].is_equal_approx(Vector2(0, 10)))
	assert_true(p[4].is_equal_approx(Vector2(10, 0)))


## CHECK: 3
func test_cr_1023_top_right_corner() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	assert_true(p[5].is_equal_approx(Vector2(90, 0)))
	assert_true(p[9].is_equal_approx(Vector2(100, 10)))


## CHECK: 4
func test_cr_1023_bottom_right_corner() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	assert_true(p[10].is_equal_approx(Vector2(100, 90)))
	assert_true(p[14].is_equal_approx(Vector2(90, 100)))


## CHECK: 5
func test_cr_1023_bottom_left_corner() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	assert_true(p[15].is_equal_approx(Vector2(10, 100)))
	assert_true(p[19].is_equal_approx(Vector2(0, 90)))


## CHECK: 6
func test_cr_1023_top_left_midpoint() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 10.0, 4)
	# Center of top-left arc is at (10, 10). Radius 10. Angle PI/4 from horizontal left?
	# The spec says: "Top Left is from (x, y + radius) to (x + radius, y)".
	# Start: (0, 10). End: (10, 0). Center: (10, 10).
	# Vector from center to start: (-10, 0). Angle PI.
	# Vector from center to end: (0, -10). Angle -PI/2 or 3PI/2.
	# Clockwise from PI to 3PI/2? No, clockwise in screen coords (y down) means angle decreases?
	# Let's check the spec description carefully.
	# "Top Left is from left edge top end (x, y + radius) to top edge left end (x + radius, y)"
	# Start: (0, 10). End: (10, 0).
	# Center: (10, 10).
	# Start vector relative to center: (-10, 0).
	# End vector relative to center: (0, -10).
	# Midpoint of arc (segments=4, so index 2 is the middle point between start and end? No, segments+1 points. Indices 0,1,2,3,4. Index 2 is the middle.)
	# The arc goes from angle PI to angle -PI/2 (or 3PI/2) clockwise?
	# In Godot, Y is down. Clockwise rotation visually corresponds to increasing angle in standard math if Y is up, but here Y is down.
	# Let's just use the formula given in the check: Vector2(10 - 10 * cos(PI / 4), 10 - 10 * sin(PI / 4)).
	# This implies the midpoint vector from center (10,10) is (-10*cos(PI/4), -10*sin(PI/4)).
	# So the point is (10 - 7.07, 10 - 7.07) = (2.93, 2.93).
	var expected_mid := Vector2(10.0 - 10.0 * cos(PI / 4.0), 10.0 - 10.0 * sin(PI / 4.0))
	assert_true(p[2].is_equal_approx(expected_mid))


## CHECK: 7
func test_cr_1023_radius_clamp() -> void:
	var p: PackedVector2Array = v.round_rect_points(Rect2(0, 0, 100, 100), 60.0, 4)
	# Radius should be clamped to min(100, 100)/2 = 50.
	# Top-left start point should be (0, 50).
	assert_true(p[0].is_equal_approx(Vector2(0, 50)))
