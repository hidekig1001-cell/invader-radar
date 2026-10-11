extends GutTest

const Rules = preload("res://core/rules.gd")
const Solver = preload("res://core/solver.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")


func _make_level_sa() -> Level:
	var lv = Level.new()
	lv.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]],
		"asteroids": [[1, 0]]
	})
	return lv


func _make_level_qa() -> Level:
	var lv = Level.new()
	lv.parse({
		"id": 2,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [[2, 0]]
	})
	return lv


## CHECK: 1
func test_solver_solutions_sa_excludes_asteroid() -> void:
	var lv = _make_level_sa()
	var sols = Solver.solutions(lv)
	assert_eq(sols.size(), 1)
	if sols.size() > 0:
		var sol = sols[0]
		assert_eq(sol, [Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)])


## CHECK: 2
func test_solver_count_solutions_sa_is_one() -> void:
	var lv = _make_level_sa()
	assert_eq(Solver.count_solutions(lv), 1)


## CHECK: 3
func test_rules_conflicts_qa_asteroid_only() -> void:
	var lv = _make_level_qa()
	var bs = BoardState.new(4, 4)
	bs.apply("place", 2, 0)
	var conflicts = Rules.conflicts(bs, lv)
	assert_eq(conflicts, [Vector2i(2, 0)])


## CHECK: 4
func test_rules_conflicts_qa_asteroid_and_valid() -> void:
	var lv = _make_level_qa()
	var bs = BoardState.new(4, 4)
	bs.apply("place", 2, 0)
	bs.apply("place", 0, 1)
	var conflicts = Rules.conflicts(bs, lv)
	assert_eq(conflicts, [Vector2i(2, 0)])


## CHECK: 5
func test_rules_is_solved_qa_asteroid_false() -> void:
	var lv = _make_level_qa()
	var bs = BoardState.new(4, 4)
	bs.apply("place", 2, 0)
	bs.apply("place", 0, 1)
	bs.apply("place", 3, 2)
	bs.apply("place", 1, 3)
	assert_false(Rules.is_solved(bs, lv))
	var conflicts = Rules.conflicts(bs, lv)
	assert_eq(conflicts, [Vector2i(2, 0)])
