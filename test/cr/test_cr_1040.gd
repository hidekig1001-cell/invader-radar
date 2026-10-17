extends GutTest

const Level = preload("res://game/level.gd")
const Rules = preload("res://core/rules.gd")
const Solver = preload("res://core/solver.gd")
const BoardState = preload("res://core/board_state.gd")


func _make_level(radar: Array) -> Level:
	var lv = Level.new()
	var d = {
		"id": 1,
		"width": 4,
		"height": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [],
		"radar": radar,
		"target": 4
	}
	lv.parse(d)
	return lv


func _make_board() -> BoardState:
	var board = BoardState.new(4, 4)
	board.apply("place", 0, 1)
	board.apply("place", 1, 3)
	board.apply("place", 2, 0)
	board.apply("place", 3, 2)
	return board


## CHECK: 1
func test_parse_radar_valid() -> void:
	var lv = Level.new()
	assert_eq(lv.parse_radar([[1, 1, 2]], 4, 4), [[1, 1, 2]])
	assert_eq(lv.parse_radar([[3, 3, 1]], 4, 4), [[3, 3, 1]])
	assert_eq(lv.parse_radar([[0, 0, 0]], 4, 4), [[0, 0, 0]])


## CHECK: 2
func test_parse_level_with_radar() -> void:
	var lv_bad = Level.new()
	var d_bad = {
		"id": 1, "width": 4, "height": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [], "radar": [[1, 1]], "target": 4
	}
	assert_false(lv_bad.parse(d_bad))

	var lv_good = Level.new()
	var d_good = {
		"id": 1, "width": 4, "height": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [], "radar": [[1, 1, 2]], "target": 4
	}
	assert_true(lv_good.parse(d_good))


## CHECK: 3
func test_write_radar_and_to_dict() -> void:
	var lv = _make_level([[1, 1, 2]])
	var dict = lv.to_dict()
	assert_eq(dict["radar"], [[1, 1, 2]])
	assert_eq(lv.write_radar([[1, 1, 2]]), [[1, 1, 2]])


## CHECK: 4
func test_radar_count() -> void:
	var pieces = [Vector2i(0, 0), Vector2i(2, 1)]
	assert_eq(Rules.radar_count(pieces, 1, 1), 2)
	
	var pieces_far = [Vector2i(3, 1)]
	assert_eq(Rules.radar_count(pieces_far, 1, 1), 0)


## CHECK: 5
func test_radar_conflicts() -> void:
	var board = _make_board()
	var lv_n1 = _make_level([[2, 2, 1]])
	var conflicts_n1 = Rules.radar_conflicts(board, lv_n1)
	assert_eq(conflicts_n1, [Vector2i(3, 2), Vector2i(1, 3)])

	var lv_n2 = _make_level([[2, 2, 2]])
	var conflicts_n2 = Rules.radar_conflicts(board, lv_n2)
	assert_eq(conflicts_n2, [])


## CHECK: 6
func test_conflicts_include_radar() -> void:
	var board = _make_board()
	var lv_n1 = _make_level([[2, 2, 1]])
	var all_conflicts = Rules.conflicts(board, lv_n1)
	assert_true(all_conflicts.has(Vector2i(3, 2)))
	assert_true(all_conflicts.has(Vector2i(1, 3)))

	var lv_n2 = _make_level([[2, 2, 2]])
	var all_conflicts_n2 = Rules.conflicts(board, lv_n2)
	assert_eq(all_conflicts_n2, [])


## CHECK: 7
func test_radar_satisfied() -> void:
	var pieces = [Vector2i(0, 1), Vector2i(1, 3), Vector2i(2, 0), Vector2i(3, 2)]
	
	var lv_n2 = _make_level([[2, 2, 2]])
	assert_true(Rules.radar_satisfied(pieces, lv_n2))

	var lv_n1 = _make_level([[2, 2, 1]])
	assert_false(Rules.radar_satisfied(pieces, lv_n1))

	var lv_n3 = _make_level([[2, 2, 3]])
	assert_false(Rules.radar_satisfied(pieces, lv_n3))


## CHECK: 8
func test_is_solved_with_radar() -> void:
	var board = _make_board()
	
	var lv_n2 = _make_level([[2, 2, 2]])
	assert_true(Rules.is_solved(board, lv_n2))

	var lv_n1 = _make_level([[2, 2, 1]])
	assert_false(Rules.is_solved(board, lv_n1))

	var lv_n3 = _make_level([[2, 2, 3]])
	assert_false(Rules.is_solved(board, lv_n3))


## CHECK: 9
func test_solver_with_radar() -> void:
	var lv_0_2_0 = _make_level([[0, 2, 0]])
	assert_eq(Solver.count_solutions(lv_0_2_0), 1)
	var sols_0_2_0 = Solver.solutions(lv_0_2_0)
	assert_eq(sols_0_2_0, [[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)]])

	var lv_2_2_2 = _make_level([[2, 2, 2]])
	assert_eq(Solver.count_solutions(lv_2_2_2), 2)

	var lv_2_2_3 = _make_level([[2, 2, 3]])
	assert_eq(Solver.count_solutions(lv_2_2_3), 0)

	var lv_0_2_2 = _make_level([[0, 2, 2]])
	var sols_0_2_2 = Solver.solutions(lv_0_2_2)
	assert_eq(sols_0_2_2, [[Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)]])
