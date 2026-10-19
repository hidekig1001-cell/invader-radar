extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Level = preload("res://game/level.gd")
const Session = preload("res://game/session.gd")
const Solver = preload("res://core/solver.gd")

const EXPECTED_REGIONS := [
	[[0, 0, 0, 1], [0, 0, 1, 1], [2, 2, 2, 1], [2, 2, 3, 1]],
	[[2, 2, 1, 1], [2, 0, 1, 3], [0, 0, 1, 3], [0, 0, 0, 3]],
	[[1, 0, 0, 0], [1, 1, 3, 3], [1, 1, 2, 2], [1, 1, 2, 2]],
	[[3, 3, 1, 1], [3, 3, 1, 1], [0, 0, 1, 1], [0, 2, 2, 1]],
	[[0, 0, 2, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 3, 3, 1]],
	[[2, 2, 2, 2, 2], [0, 2, 2, 2, 2], [0, 2, 2, 2, 1], [0, 4, 4, 2, 3], [0, 4, 4, 3, 3]],
	[[2, 0, 0, 4, 4], [2, 2, 0, 1, 4], [2, 2, 0, 4, 4], [2, 2, 0, 0, 4], [3, 3, 3, 3, 3]],
	[[3, 3, 1, 2, 1], [3, 3, 1, 1, 1], [3, 3, 1, 1, 0], [3, 3, 1, 4, 0], [3, 4, 4, 4, 0]],
	[[0, 0, 0, 3, 3], [0, 0, 0, 3, 3], [2, 2, 2, 2, 2], [1, 1, 1, 1, 2], [1, 1, 1, 1, 4]],
	[[1, 2, 2, 2, 1], [1, 1, 1, 1, 1], [3, 0, 0, 0, 1], [3, 3, 0, 0, 1], [3, 3, 4, 4, 1]],
]

const EXPECTED_SOLUTIONS := [
	[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)],
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)],
	[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)],
	[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3)],
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)],
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(4, 2), Vector2i(1, 3), Vector2i(3, 4)],
	[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(4, 3), Vector2i(2, 4)],
	[Vector2i(3, 0), Vector2i(0, 1), Vector2i(2, 2), Vector2i(4, 3), Vector2i(1, 4)],
	[Vector2i(1, 0), Vector2i(3, 1), Vector2i(0, 2), Vector2i(2, 3), Vector2i(4, 4)],
	[Vector2i(1, 0), Vector2i(4, 1), Vector2i(2, 2), Vector2i(0, 3), Vector2i(3, 4)],
]

## CHECK: 1
func test_level_dicts_size_is_10() -> void:
	var dicts := LevelPack.level_dicts()
	assert_eq(dicts.size(), 25)

## CHECK: 2
func test_level_dicts_ids_are_sequential() -> void:
	var dicts := LevelPack.level_dicts()
	for i in range(10):
		assert_eq(dicts[i]["id"], i + 1)

## CHECK: 3
func test_level_dicts_regions_match_table() -> void:
	var dicts := LevelPack.level_dicts()
	assert_eq(dicts[0]["regions"], [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]])
	assert_eq(dicts[1]["regions"], [[0, 0, 2, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 3, 3, 1]])
	assert_eq(dicts[2]["regions"], EXPECTED_REGIONS[2])
	assert_eq(dicts[3]["regions"], EXPECTED_REGIONS[3])
	assert_eq(dicts[4]["regions"], [[2, 2, 1, 1], [2, 0, 1, 3], [0, 0, 1, 3], [0, 0, 0, 3]])
	for i in range(5, 10):
		assert_eq(dicts[i]["regions"], EXPECTED_REGIONS[i])

## CHECK: 4
func test_level_dicts_dimensions() -> void:
	var dicts := LevelPack.level_dicts()
	for i in range(10):
		var expected_size := 4 if i < 5 else 5
		assert_eq(dicts[i]["width"], expected_size)
		assert_eq(dicts[i]["height"], expected_size)
		assert_eq(dicts[i]["target"], expected_size)

## CHECK: 5
func test_level_dicts_parse_success() -> void:
	var dicts := LevelPack.level_dicts()
	for i in range(10):
		var lv := Level.new()
		assert_true(lv.parse(dicts[i]))

## CHECK: 6
func test_level_dicts_have_unique_solution() -> void:
	var dicts := LevelPack.level_dicts()
	for i in range(10):
		var lv := Level.new()
		lv.parse(dicts[i])
		assert_eq(Solver.count_solutions(lv, 2), 1)

## CHECK: 7
func test_level_dicts_solutions_match_table() -> void:
	var dicts := LevelPack.level_dicts()
	for i in range(10):
		var lv := Level.new()
		lv.parse(dicts[i])
		var sols := Solver.solutions(lv)
		assert_eq(sols[0], EXPECTED_SOLUTIONS[i])

## CHECK: 8
func test_session_load_default_levels_size() -> void:
	var levels := Session.load_default_levels()
	assert_eq(levels.size(), 25)

## CHECK: 9
func test_session_load_default_levels_ids() -> void:
	var levels := Session.load_default_levels()
	for i in range(10):
		assert_eq(levels[i].id, i + 1)
