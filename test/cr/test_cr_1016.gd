extends GutTest

const LevelPack = preload("res://game/level_pack.gd")

## CHECK: 1
func test_level_2_regions_swapped() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts[1]["regions"], [[0, 0, 2, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 3, 3, 1]])

## CHECK: 1
func test_level_5_regions_swapped() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts[4]["regions"], [[2, 2, 1, 1], [2, 0, 1, 3], [0, 0, 1, 3], [0, 0, 0, 3]])
