extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")


func _make_session() -> SessionScript:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [[3, 3]],
		"radar": [[0, 0, 1]]
	})
	return SessionScript.new([level])


## CHECK: 1
func test_is_radar() -> void:
	var s = _make_session()
	assert_true(s.is_radar(0, 0))
	assert_false(s.is_radar(1, 0))
	assert_false(s.is_radar(3, 3))


## CHECK: 2
func test_tap_and_double_tap_on_radar() -> void:
	var s = _make_session()
	assert_false(s.tap(0, 0))
	assert_false(s.double_tap(0, 0))
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.moves, 0)
	
	assert_true(s.tap(1, 0))
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.moves, 1)


## CHECK: 3
func test_swipe_on_radar() -> void:
	var s = _make_session()
	assert_false(s.swipe([Vector2i(0, 0)]))
	assert_eq(s.moves, 0)
	
	assert_true(s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]))
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.board.state_at(2, 0), 1)
	assert_eq(s.moves, 1)
