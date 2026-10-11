extends GutTest

const Session = preload("res://game/session.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")


func _make_session() -> Session:
	var lv = Level.new()
	lv.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]],
		"asteroids": [[1, 1]]
	})
	return Session.new([lv])


## CHECK: 1
func test_is_asteroid() -> void:
	var s = _make_session()
	assert_true(s.is_asteroid(1, 1))
	assert_false(s.is_asteroid(0, 0))


## CHECK: 2
func test_tap_on_asteroid() -> void:
	var s = _make_session()
	assert_false(s.tap(1, 1))
	assert_eq(s.moves, 0)
	assert_true(s.tap(0, 0))
	assert_eq(s.moves, 1)


## CHECK: 3
func test_double_tap_on_asteroid() -> void:
	var s = _make_session()
	assert_false(s.double_tap(1, 1))
	assert_eq(s.moves, 0)
	assert_true(s.double_tap(0, 0))
	assert_eq(s.moves, 1)


## CHECK: 4
func test_swipe_on_asteroid_only() -> void:
	var s = _make_session()
	assert_false(s.swipe([Vector2i(1, 1)]))
	assert_eq(s.moves, 0)
	assert_true(s.swipe([Vector2i(0, 0)]))
	assert_eq(s.moves, 1)


## CHECK: 5
func test_swipe_mixed_asteroid_and_empty() -> void:
	var s = _make_session()
	assert_true(s.swipe([Vector2i(1, 1), Vector2i(2, 2)]))
	assert_eq(s.board.state_at(1, 1), BoardState.EMPTY)
	assert_eq(s.board.state_at(2, 2), BoardState.MARK)
