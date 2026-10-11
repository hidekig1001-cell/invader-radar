extends GutTest

## CHECK: 1
func test_level_1_regions_are_easy_4x4() -> void:
	var dicts = preload("res://game/level_pack.gd").level_dicts()
	assert_eq(dicts[0]["regions"], [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]])
