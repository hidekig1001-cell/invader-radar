extends GutTest

const Rules = preload("res://core/rules.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")


func _make_level_q() -> Level:
	var l = Level.new()
	l.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	return l


func _make_level_r() -> Level:
	var l = Level.new()
	l.parse({"id": 2, "width": 4, "height": 4, "target": 4, "regions": [[3, 3, 0, 0], [3, 3, 1, 2], [1, 1, 1, 2], [1, 1, 1, 2]]})
	return l


func _make_board_with_pieces(coords: Array) -> BoardState:
	var b = BoardState.new(4, 4)
	for c in coords:
		b.apply("place", c.x, c.y)
	return b


## CHECK: 1
func test_cr_1001_check_1() -> void:
	var level_q = _make_level_q()
	
	# Case 1: Solved state
	var b1 = _make_board_with_pieces([Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)])
	assert_true(Rules.is_solved(b1, level_q))
	
	# Case 2: Unsolved state (diagonal neighbors)
	var b2 = _make_board_with_pieces([Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)])
	assert_false(Rules.is_solved(b2, level_q))


## CHECK: 2
func test_cr_1001_check_2() -> void:
	var level_q = _make_level_q()
	var b = _make_board_with_pieces([Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)])
	assert_false(Rules.is_solved(b, level_q))


## CHECK: 3
func test_cr_1001_check_3() -> void:
	var level_q = _make_level_q()
	var b = _make_board_with_pieces([Vector2i(0, 0), Vector2i(3, 0)])
	var expected = [Vector2i(0, 0), Vector2i(3, 0)]
	assert_eq(Rules.conflicts(b, level_q), expected)


## CHECK: 4
func test_cr_1001_check_4() -> void:
	var level_q = _make_level_q()
	var b = _make_board_with_pieces([Vector2i(1, 0), Vector2i(1, 3)])
	var expected = [Vector2i(1, 0), Vector2i(1, 3)]
	assert_eq(Rules.conflicts(b, level_q), expected)


## CHECK: 5
func test_cr_1001_check_5() -> void:
	var level_q = _make_level_q()
	var b = _make_board_with_pieces([Vector2i(1, 1), Vector2i(2, 2)])
	var expected = [Vector2i(1, 1), Vector2i(2, 2)]
	assert_eq(Rules.conflicts(b, level_q), expected)


## CHECK: 6
func test_cr_1001_check_6() -> void:
	var level_r = _make_level_r()
	var b = _make_board_with_pieces([Vector2i(2, 1), Vector2i(0, 3)])
	var expected = [Vector2i(2, 1), Vector2i(0, 3)]
	assert_eq(Rules.conflicts(b, level_r), expected)


## CHECK: 7
func test_cr_1001_check_7() -> void:
	var level_q = _make_level_q()
	# Order of placement: (3,3), (0,0), (3,0), (1,2)
	var b = _make_board_with_pieces([Vector2i(3, 3), Vector2i(0, 0), Vector2i(3, 0), Vector2i(1, 2)])
	# Conflicts:
	# (0,0) and (3,0) share row y=0.
	# (3,0) and (3,3) share col x=3.
	# (1,2) is isolated.
	# Expected sorted by y then x:
	# y=0: (0,0), (3,0)
	# y=3: (3,3)
	var expected = [Vector2i(0, 0), Vector2i(3, 0), Vector2i(3, 3)]
	assert_eq(Rules.conflicts(b, level_q), expected)


## CHECK: 8
func test_cr_1001_check_8() -> void:
	var level_q = _make_level_q()
	var b = _make_board_with_pieces([Vector2i(2, 0), Vector2i(0, 1)])
	assert_eq(Rules.conflicts(b, level_q), [])
	
	b.apply("place", 3, 0)
	var expected = [Vector2i(2, 0), Vector2i(3, 0)]
	assert_eq(Rules.conflicts(b, level_q), expected)
