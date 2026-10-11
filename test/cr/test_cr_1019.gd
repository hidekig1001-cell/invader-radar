extends GutTest

const BoardView = preload("res://scenes/board_view.gd")


func _make_board_view() -> Node2D:
	var v = BoardView.new()
	autofree(v)
	return v


## CHECK: 1
func test_alien_rows_content() -> void:
	var v = _make_board_view()
	var expected := [
		"....1...",
		"...1....",
		"..1111..",
		".111111.",
		"11122111",
		"11122111",
		".111111.",
		"..1..1.."
	]
	assert_eq(v.alien_rows(), expected)


## CHECK: 2
func test_alien_pixel_rect_top_left() -> void:
	var v = _make_board_view()
	var r := Rect2(0, 0, 100, 100)
	var result: Rect2 = v.alien_pixel_rect(r, 0, 0)
	assert_true(result.is_equal_approx(Rect2(22, 22, 7, 7)))


## CHECK: 3
func test_alien_pixel_rect_bottom_right() -> void:
	var v = _make_board_view()
	var r := Rect2(0, 0, 100, 100)
	var result: Rect2 = v.alien_pixel_rect(r, 7, 7)
	assert_true(result.is_equal_approx(Rect2(71, 71, 7, 7)))


## CHECK: 4
func test_alien_pixel_rect_middle() -> void:
	var v = _make_board_view()
	var r := Rect2(0, 0, 100, 100)
	var result: Rect2 = v.alien_pixel_rect(r, 3, 4)
	assert_true(result.is_equal_approx(Rect2(43, 50, 7, 7)))


## CHECK: 5
func test_alien_pixel_rect_offset_cell() -> void:
	var v = _make_board_view()
	var r := Rect2(100, 200, 50, 50)
	var result: Rect2 = v.alien_pixel_rect(r, 1, 2)
	assert_true(result.is_equal_approx(Rect2(114.5, 218, 3.5, 3.5)))
