extends GutTest

const Solver = preload("res://core/solver.gd")
const Level = preload("res://game/level.gd")
const BoardState = preload("res://core/board_state.gd")
const Rules = preload("res://core/rules.gd")

func _make_level(width: int, height: int, target: int, regions: Array) -> Level:
	var l = Level.new()
	l.parse({
		"id": 1,
		"width": width,
		"height": height,
		"target": target,
		"regions": regions
	})
	return l

func _level_r() -> Level:
	return _make_level(4, 4, 4, [[3, 3, 0, 0], [3, 3, 1, 2], [1, 1, 1, 2], [1, 1, 1, 2]])

func _level_s() -> Level:
	return _make_level(4, 4, 4, [[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]])

func _level_f() -> Level:
	return _make_level(5, 5, 5, [[2, 2, 2, 2, 2], [0, 2, 2, 2, 2], [0, 2, 2, 2, 1], [0, 4, 4, 2, 3], [0, 4, 4, 3, 3]])

func _level_u() -> Level:
	return _make_level(4, 4, 4, [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])

## CHECK: 1
func test_solutions_level_r() -> void:
	var expected = [[Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)]]
	assert_eq(Solver.solutions(_level_r()), expected)

## CHECK: 2
func test_solutions_level_s() -> void:
	var expected = [
		[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)],
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)]
	]
	assert_eq(Solver.solutions(_level_s()), expected)

## CHECK: 3
func test_count_solutions_level_s() -> void:
	assert_eq(Solver.count_solutions(_level_s()), 2)

## CHECK: 4
func test_solutions_level_s_limit_1() -> void:
	var expected = [[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)]]
	assert_eq(Solver.solutions(_level_s(), 1), expected)

## CHECK: 5
func test_count_solutions_level_s_limit_1() -> void:
	assert_eq(Solver.count_solutions(_level_s(), 1), 1)

## CHECK: 6
func test_solutions_level_f() -> void:
	var expected = [[Vector2i(2, 0), Vector2i(0, 1), Vector2i(4, 2), Vector2i(1, 3), Vector2i(3, 4)]]
	assert_eq(Solver.solutions(_level_f()), expected)

## CHECK: 7
func test_count_solutions_level_u_and_r() -> void:
	assert_eq(Solver.count_solutions(_level_u()), 0)
	assert_eq(Solver.count_solutions(_level_r()), 1)

## CHECK: 8
func test_solutions_level_s_valid_placements() -> void:
	var solutions = Solver.solutions(_level_s())
	assert_eq(solutions.size(), 2)
	for sol in solutions:
		var board = BoardState.new(4, 4)
		for pos in sol:
			board.apply("place", pos.x, pos.y)
		assert_true(Rules.is_solved(board, _level_s()))
