extends GutTest

## CHECK: 1
func test_generated_specs_content() -> void:
	var LevelPack = load("res://game/level_pack.gd")
	assert_eq(LevelPack.GENERATED_SPECS.size(), 90)
	assert_eq(LevelPack.GENERATED_SPECS[0], [11, 5, 1, 4, 3])
	assert_eq(LevelPack.GENERATED_SPECS[9], [20, 5, 10, 1, 1])
	assert_eq(LevelPack.GENERATED_SPECS[10], [21, 6, 1, 5, 3])
	assert_eq(LevelPack.GENERATED_SPECS[29], [40, 6, 20, 1, 1])
	assert_eq(LevelPack.GENERATED_SPECS[30], [41, 7, 1, 6, 4])
	assert_eq(LevelPack.GENERATED_SPECS[59], [70, 7, 30, 2, 1])
	assert_eq(LevelPack.GENERATED_SPECS[60], [71, 8, 1, 7, 4])
	assert_eq(LevelPack.GENERATED_SPECS[89], [100, 8, 30, 4, 2])

## CHECK: 2
func test_level_dicts_and_solutions() -> void:
	var LevelPack = load("res://game/level_pack.gd")
	var Level = load("res://game/level.gd")
	var Solver = load("res://core/solver.gd")
	var dicts = LevelPack.level_dicts()
	
	# Check level 11 (index 10)
	assert_eq(dicts[10]["radar"].size(), 4)
	assert_eq(dicts[10]["asteroids"].size(), 3)
	var lv = Level.new()
	lv.parse(dicts[10])
	assert_eq(Solver.count_solutions(lv, 2), 1)
	
	# Check level 100 (index 99)
	assert_eq(dicts[99]["radar"].size(), 4)
	var lv2 = Level.new()
	lv2.parse(dicts[99])
	assert_eq(Solver.count_solutions(lv2, 2), 1)
