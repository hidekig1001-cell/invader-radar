extends GutTest

const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const LevelPack = preload("res://game/level_pack.gd")
const Solver = preload("res://core/solver.gd")


func test_random_generation_differs_by_seed() -> void:
	## CHECK: 1
	var s1 = Session.new()
	s1.rng.seed = 1
	s1.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	var regions1 = s1.level.regions.to_rows()

	var s2 = Session.new()
	s2.rng.seed = 2
	s2.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	var regions2 = s2.level.regions.to_rows()

	assert_ne(regions1, regions2)
	assert_eq(s1.level.id, 14)
	assert_eq(s1.level.width, 5)
	assert_eq(Solver.count_solutions(s1.level, 2), 1)
	assert_eq(s2.level.id, 14)
	assert_eq(s2.level.width, 5)
	assert_eq(Solver.count_solutions(s2.level, 2), 1)


func test_random_generation_differs_from_default() -> void:
	## CHECK: 2
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	var generated_regions = s.level.regions.to_rows()

	var default_dicts = LevelPack.level_dicts()
	var default_level = Level.new()
	default_level.parse(default_dicts[13])
	var default_regions = default_level.regions.to_rows()

	assert_ne(generated_regions, default_regions)
