extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const LevelPack = preload("res://game/level_pack.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_level_dicts_size_and_generated_levels_match() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 35)
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)
	assert_eq(dicts[10], gen[0])
	assert_eq(dicts[11], gen[1])
	assert_eq(dicts[12], gen[2])
	assert_eq(dicts[13], gen[3])
	assert_eq(dicts[14], gen[4])
	for k in range(5, 25):
		assert_eq(dicts[10 + k], gen[k])


## CHECK: 2
func test_level_dicts_ids_and_generated_levels_ids() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts[10].get("id"), 11)
	assert_eq(dicts[11].get("id"), 12)
	assert_eq(dicts[12].get("id"), 13)
	var gen = LevelPack.generated_levels()
	assert_eq(gen[0].get("id"), 11)
	assert_eq(gen[1].get("id"), 12)
	assert_eq(gen[2].get("id"), 13)


## CHECK: 3
func test_level_dicts_dimensions_and_generated_levels_dimensions() -> void:
	var dicts = LevelPack.level_dicts()
	for i in range(10, 15):
		assert_eq(dicts[i].get("width"), 6)
		assert_eq(dicts[i].get("height"), 6)
		assert_eq(dicts[i].get("target"), 6)
	for i in range(15, 25):
		assert_eq(dicts[i].get("width"), 7)
		assert_eq(dicts[i].get("height"), 7)
		assert_eq(dicts[i].get("target"), 7)
	for i in range(25, 35):
		assert_eq(dicts[i].get("width"), 8)
		assert_eq(dicts[i].get("height"), 8)
		assert_eq(dicts[i].get("target"), 8)
	var gen = LevelPack.generated_levels()
	for d in gen:
		if d.get("id") <= 15:
			assert_eq(d.get("width"), 6)
			assert_eq(d.get("height"), 6)
			assert_eq(d.get("target"), 6)
		elif d.get("id") <= 25:
			assert_eq(d.get("width"), 7)
			assert_eq(d.get("height"), 7)
			assert_eq(d.get("target"), 7)
		else:
			assert_eq(d.get("width"), 8)
			assert_eq(d.get("height"), 8)
			assert_eq(d.get("target"), 8)


## CHECK: 4
func test_generated_levels_size_and_ids() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)
	assert_eq(gen[0].get("id"), 11)
	assert_eq(gen[1].get("id"), 12)
	assert_eq(gen[2].get("id"), 13)
	assert_eq(gen[3].get("id"), 14)
	assert_eq(gen[4].get("id"), 15)
	assert_eq(gen[5].get("id"), 16)
	assert_eq(gen[6].get("id"), 17)
	assert_eq(gen[7].get("id"), 18)
	assert_eq(gen[8].get("id"), 19)
	assert_eq(gen[9].get("id"), 20)
	assert_eq(gen[10].get("id"), 21)
	assert_eq(gen[11].get("id"), 22)
	assert_eq(gen[12].get("id"), 23)
	assert_eq(gen[13].get("id"), 24)
	assert_eq(gen[14].get("id"), 25)
	assert_eq(gen[15].get("id"), 26)
	assert_eq(gen[16].get("id"), 27)
	assert_eq(gen[17].get("id"), 28)
	assert_eq(gen[18].get("id"), 29)
	assert_eq(gen[19].get("id"), 30)
	assert_eq(gen[20].get("id"), 31)
	assert_eq(gen[21].get("id"), 32)
	assert_eq(gen[22].get("id"), 33)
	assert_eq(gen[23].get("id"), 34)
	assert_eq(gen[24].get("id"), 35)


## CHECK: 5
func test_generated_levels_dimensions() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)
	for i in range(gen.size()):
		var d = gen[i]
		assert_true(d is Dictionary)
		if i < 5:
			assert_eq(d.get("width"), 6)
			assert_eq(d.get("height"), 6)
			assert_eq(d.get("target"), 6)
		elif i < 15:
			assert_eq(d.get("width"), 7)
			assert_eq(d.get("height"), 7)
			assert_eq(d.get("target"), 7)
		else:
			assert_eq(d.get("width"), 8)
			assert_eq(d.get("height"), 8)
			assert_eq(d.get("target"), 8)


## CHECK: 6
func test_attempt_level_seed_1_returns_valid_dict() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 1
	var result = LevelMaker.attempt_level(rng, 6)
	assert_true(result is Dictionary)
	assert_eq(result.get("id"), 0)
	assert_eq(result.get("width"), 6)
	assert_eq(result.get("height"), 6)
	assert_eq(result.get("target"), 6)


## CHECK: 7
func test_attempt_level_same_seed_same_regions() -> void:
	var rng1 = RandomNumberGenerator.new()
	rng1.seed = 1
	var res1 = LevelMaker.attempt_level(rng1, 6)
	var rng2 = RandomNumberGenerator.new()
	rng2.seed = 1
	var res2 = LevelMaker.attempt_level(rng2, 6)
	assert_true(res1 is Dictionary)
	assert_true(res2 is Dictionary)
	assert_eq(res1.get("regions"), res2.get("regions"))
	assert_eq(res1.get("width"), 6)
	assert_eq(res2.get("width"), 6)


## CHECK: 8
func test_attempt_level_different_seed_different_regions() -> void:
	var rng1 = RandomNumberGenerator.new()
	rng1.seed = 1
	var res1 = LevelMaker.attempt_level(rng1, 6)
	var rng2 = RandomNumberGenerator.new()
	rng2.seed = 2
	var res2 = LevelMaker.attempt_level(rng2, 6)
	assert_true(res1 is Dictionary)
	assert_true(res2 is Dictionary)
	assert_ne(res1.get("regions"), res2.get("regions"))


## CHECK: 9
func test_generated_levels_regions_are_different() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)
	for d in gen:
		assert_true(d is Dictionary)
	assert_ne(gen[0].get("regions"), gen[1].get("regions"))
	assert_ne(gen[1].get("regions"), gen[2].get("regions"))
	assert_ne(gen[0].get("regions"), gen[2].get("regions"))
	assert_ne(gen[3].get("regions"), gen[4].get("regions"))


## CHECK: 10
func test_generated_levels_have_unique_solutions() -> void:
	var gen = LevelPack.generated_levels()
	assert_eq(gen.size(), 25)
	for d in gen:
		assert_true(d is Dictionary)
		var level = Level.new()
		assert_true(level.parse(d))
		var count = Solver.count_solutions(level, 2)
		assert_eq(count, 1)
