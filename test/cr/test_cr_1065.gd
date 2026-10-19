extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_generated_specs() -> void:
	var expected = [
		[11, 6, 1], [12, 6, 2], [13, 6, 3], [14, 6, 4], [15, 6, 5],
		[16, 7, 1], [17, 7, 2], [18, 7, 3], [19, 7, 4], [20, 7, 5],
		[21, 7, 6], [22, 7, 7], [23, 7, 8], [24, 7, 9], [25, 7, 10],
		[26, 8, 1], [27, 8, 2], [28, 8, 3], [29, 8, 4], [30, 8, 5],
		[31, 8, 6], [32, 8, 7], [33, 8, 8], [34, 8, 9], [35, 8, 10]
	]
	assert_eq(LevelPack.GENERATED_SPECS, expected)


## CHECK: 2
func test_load_default_levels_size_and_new_levels() -> void:
	var levels = Session.load_default_levels()
	assert_eq(levels.size(), 35)
	for i in range(25, 35):
		var level = levels[i]
		assert_eq(level.id, i + 1)
		assert_eq(level.width, 8)
		assert_eq(level.height, 8)
		assert_eq(level.target, 8)
		var expected_rows = [
			"00000000", "11111111", "22222222", "33333333",
			"44444444", "55555555", "66666666", "77777777"
		]
		assert_eq(level.regions.to_rows(), expected_rows)


## CHECK: 3
func test_level_dicts_size_and_new_levels() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 35)
	for i in range(25, 35):
		var d = dicts[i]
		assert_eq(d["id"], i + 1)
		assert_eq(d["width"], 8)
		assert_eq(d["height"], 8)
		assert_eq(d["target"], 8)
		var radar_count = d.get("radar", []).size()
		assert_true(radar_count >= 3 and radar_count <= 5)
		var asteroid_count = d.get("asteroids", []).size()
		assert_true(asteroid_count == 1 or asteroid_count == 2)
		var level = Level.new()
		assert_true(level.parse(d))
		assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 4
func test_session_next_level_to_new_levels() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 24, "score": 0, "hints": 3})
	s.next_level()
	assert_eq(s.level_index, 25)
	assert_eq(s.level.id, 26)
	assert_eq(s.level.width, 8)
	assert_eq(Solver.count_solutions(s.level, 2), 1)
