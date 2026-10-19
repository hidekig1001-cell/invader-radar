extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_cr_1070_radar_cells_in_fixed_levels() -> void:
	var dicts = LevelPack.fixed_level_dicts()
	assert_eq(dicts.size(), 10)
	assert_eq(dicts[5].get("radar"), [[1, 0, 2], [3, 3, 2], [0, 4, 1]])
	assert_eq(dicts[6].get("radar"), [[0, 4, 0], [2, 1, 2], [3, 2, 2]])
	assert_eq(dicts[7].get("radar"), [[1, 1, 2], [3, 2, 2], [4, 4, 1]])
	assert_eq(dicts[8].get("radar"), [[0, 4, 0], [2, 1, 2], [2, 2, 2]])
	assert_eq(dicts[9].get("radar"), [[1, 1, 2], [3, 3, 2], [4, 0, 1]])


## CHECK: 2
func test_cr_1070_new_asteroids_and_unique_solutions() -> void:
	var dicts = LevelPack.fixed_level_dicts()
	assert_eq(dicts[6].get("asteroids"), [[4, 0], [1, 3]])
	assert_eq(dicts[9].get("asteroids"), [[0, 0], [2, 4]])

	for i in range(5, 10):
		var level = Level.new()
		var parsed = level.parse(dicts[i])
		assert_true(parsed)
		var count = Solver.count_solutions(level, 2)
		assert_eq(count, 1)
