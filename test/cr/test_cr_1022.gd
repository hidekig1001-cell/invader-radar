extends GutTest

const BoardView = preload("res://scenes/board_view.gd")
const Session = preload("res://game/session.gd")


func _make_board_view() -> BoardView:
	var v = BoardView.new()
	autofree(v)
	v.session = Session.new()
	return v


## CHECK: 1
func test_tile_rect_values() -> void:
	var v = _make_board_view()
	assert_true(v.tile_rect(0, 0).is_equal_approx(Rect2(50, 490, 230, 230)))
	assert_true(v.tile_rect(3, 3).is_equal_approx(Rect2(800, 1240, 230, 230)))


## CHECK: 2
func test_corner_radius_value() -> void:
	var v = _make_board_view()
	assert_almost_eq(v.corner_radius(), 45.0, 0.0001)


## CHECK: 3
func test_board_bg_rect_value() -> void:
	var v = _make_board_view()
	assert_true(v.board_bg_rect().is_equal_approx(Rect2(26, 466, 1028, 1028)))


## CHECK: 4
func test_mark_color_value() -> void:
	var v = _make_board_view()
	assert_true(v.mark_color().is_equal_approx(Color(0.25, 0.22, 0.40)))


## CHECK: 5
func test_mark_thickness_value() -> void:
	var v = _make_board_view()
	assert_almost_eq(v.mark_thickness(), 12.0, 0.0001)


## CHECK: 6
func test_region_color_0_value() -> void:
	var v = _make_board_view()
	assert_true(v.region_color(0).is_equal_approx(Color(1.0, 0.72, 0.45)))


## CHECK: 7
func test_region_color_1_value() -> void:
	var v = _make_board_view()
	assert_true(v.region_color(1).is_equal_approx(Color(0.55, 0.78, 1.0)))


## CHECK: 8
func test_region_color_2_value() -> void:
	var v = _make_board_view()
	assert_true(v.region_color(2).is_equal_approx(Color(0.58, 0.88, 0.55)))


## CHECK: 9
func test_region_color_3_value() -> void:
	var v = _make_board_view()
	assert_true(v.region_color(3).is_equal_approx(Color(0.80, 0.65, 0.95)))


## CHECK: 10
func test_region_color_4_value() -> void:
	var v = _make_board_view()
	assert_true(v.region_color(4).is_equal_approx(Color(1.0, 0.62, 0.66)))
