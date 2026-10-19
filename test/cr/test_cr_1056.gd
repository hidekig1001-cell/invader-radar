extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_generated_levels_size_is_5() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)


## CHECK: 2
func test_generated_levels_index3_id_is_14() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen[3]["id"], 14)


## CHECK: 3
func test_generated_levels_index4_id_is_15() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen[4]["id"], 15)


## CHECK: 4
func test_level_dicts_size_is_15() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 35)


## CHECK: 5
func test_level_dicts_index13_id_is_14() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts[13]["id"], 14)


## CHECK: 6
func test_level_dicts_index14_id_is_15() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts[14]["id"], 15)


## CHECK: 7
func test_level_dicts_index13_matches_make_level_6_6_4() -> void:
	var dicts = LevelPack.level_dicts()
	var actual = dicts[13].duplicate(true)
	actual.erase("id")
	var expected = LevelMaker.make_level(6, 6, 4).duplicate(true)
	expected.erase("id")
	assert_eq(actual, expected)


## CHECK: 8
func test_level_dicts_index14_matches_make_level_6_6_5() -> void:
	var dicts = LevelPack.level_dicts()
	var actual = dicts[14].duplicate(true)
	actual.erase("id")
	var expected = LevelMaker.make_level(6, 6, 5).duplicate(true)
	expected.erase("id")
	assert_eq(actual, expected)


## CHECK: 9
func test_level_dicts_index13_parses_and_has_unique_solution() -> void:
	var dicts = LevelPack.level_dicts()
	var level = Level.new()
	var ok = level.parse(dicts[13])
	assert_true(ok)
	var count = Solver.count_solutions(level, 2)
	assert_eq(count, 1)


## CHECK: 10
func test_level_dicts_index14_parses_and_has_unique_solution() -> void:
	var dicts = LevelPack.level_dicts()
	var level = Level.new()
	var ok = level.parse(dicts[14])
	assert_true(ok)
	var count = Solver.count_solutions(level, 2)
	assert_eq(count, 1)
