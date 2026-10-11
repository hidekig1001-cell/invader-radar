extends GutTest

const BoardView = preload("res://scenes/board_view.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")

func _make_session() -> Session:
	var s = Session.new()
	var l = Level.new()
	l.parse({
		"width": 4,
		"height": 4,
		"regions": [
			[0, 0, 0, 1],
			[0, 0, 1, 1],
			[2, 2, 2, 1],
			[2, 2, 3, 1]
		]
	})
	s.level = l
	return s

## CHECK: 1
func test_conflicting_pieces_are_red() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = Session.new()
	v.session.double_tap(0, 0)
	v.session.double_tap(3, 0)
	assert_true(v.piece_fill(0, 0).is_equal_approx(Color(0.90, 0.15, 0.15)))
	assert_true(v.piece_fill(3, 0).is_equal_approx(Color(0.90, 0.15, 0.15)))

## CHECK: 2
func test_removing_conflict_restores_color() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = Session.new()
	v.session.double_tap(0, 0)
	v.session.double_tap(3, 0)
	v.session.double_tap(3, 0)
	assert_true(v.piece_fill(0, 0).is_equal_approx(Color(0.08, 0.08, 0.12)))

## CHECK: 3
func test_non_conflicting_then_conflicting() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = Session.new()
	v.session.double_tap(1, 0)
	v.session.double_tap(3, 1)
	assert_true(v.piece_fill(1, 0).is_equal_approx(Color(0.08, 0.08, 0.12)))
	v.session.double_tap(2, 1)
	assert_true(v.piece_fill(1, 0).is_equal_approx(Color(0.90, 0.15, 0.15)))
