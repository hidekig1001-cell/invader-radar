extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_make_level_parses() -> void:
	var d = LevelMaker.make_level(6, 6, 1)
	assert_true(d.has("id"))
	assert_true(d.has("width"))
	assert_true(d.has("height"))
	assert_true(d.has("target"))
	assert_true(d.has("regions"))
	var level = Level.new()
	assert_true(level.parse(d))


## CHECK: 2
func test_make_level_target_is_size() -> void:
	var d = LevelMaker.make_level(6, 6, 1)
	assert_eq(d["target"], 6)


## CHECK: 3
func test_make_level_region_ids_are_0_to_5() -> void:
	var d = LevelMaker.make_level(6, 6, 1)
	var seen := {}
	for row in d["regions"]:
		for cell in row:
			seen[cell] = true
	assert_eq(seen.size(), 6)
	for i in range(6):
		assert_true(seen.has(i))


## CHECK: 4
func test_make_level_seed1_has_unique_solution() -> void:
	var d = LevelMaker.make_level(6, 6, 1)
	assert_true(d.has("regions"))
	var level = Level.new()
	level.parse(d)
	assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 5
func test_make_level_seed2_has_unique_solution() -> void:
	var d = LevelMaker.make_level(6, 6, 2)
	assert_true(d.has("regions"))
	var level = Level.new()
	level.parse(d)
	assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 6
func test_make_level_seed3_has_unique_solution() -> void:
	var d = LevelMaker.make_level(6, 6, 3)
	assert_true(d.has("regions"))
	var level = Level.new()
	level.parse(d)
	assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 7
func test_make_level_is_deterministic_for_same_seed() -> void:
	var a = LevelMaker.make_level(6, 6, 1)
	var b = LevelMaker.make_level(6, 6, 1)
	assert_eq(a["regions"], b["regions"])


## CHECK: 8
func test_make_level_4x4_has_unique_solution() -> void:
	var d = LevelMaker.make_level(4, 4, 1)
	assert_true(d.has("regions"))
	var level = Level.new()
	level.parse(d)
	assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 9
func test_pick_solution_returns_size_distinct_columns() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var sol = LevelMaker.pick_solution(rng, 6)
	assert_eq(sol.size(), 6)
	var seen := {}
	for col in sol:
		assert_false(seen.has(col))
		seen[col] = true


## CHECK: 10
func test_has_unique_solution_true_for_generated_and_false_for_all_zero() -> void:
	var d = LevelMaker.make_level(6, 6, 1)
	assert_true(LevelMaker.has_unique_solution(d))
	var all_zero := {
		"id": 99,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
	}
	assert_false(LevelMaker.has_unique_solution(all_zero))
