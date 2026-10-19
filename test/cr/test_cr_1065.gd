extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_generated_specs() -> void:
	var expected = [
		[11, 5, 1, 2, 1], [12, 5, 2, 2, 1], [13, 5, 3, 2, 1], [14, 5, 4, 1, 1], [15, 5, 5, 1, 1],
		[16, 5, 6, 1, 0], [17, 5, 7, 1, 0], [18, 5, 8, 0, 0], [19, 5, 9, 0, 0], [20, 5, 10, 0, 0],
		[21, 6, 1, 4, 2], [22, 6, 2, 4, 2], [23, 6, 3, 4, 2], [24, 6, 4, 4, 2], [25, 6, 5, 3, 2],
		[26, 6, 6, 3, 1], [27, 6, 7, 3, 1], [28, 6, 8, 3, 1], [29, 6, 9, 3, 1], [30, 6, 10, 3, 1],
		[31, 6, 11, 2, 1], [32, 6, 12, 2, 1], [33, 6, 13, 2, 1], [34, 6, 14, 2, 1], [35, 6, 15, 2, 1],
		[36, 6, 16, 2, 0], [37, 6, 17, 1, 0], [38, 6, 18, 1, 0], [39, 6, 19, 1, 0], [40, 6, 20, 1, 0],
		[41, 7, 1, 4, 2], [42, 7, 2, 4, 2], [43, 7, 3, 4, 2], [44, 7, 4, 4, 2], [45, 7, 5, 4, 2],
		[46, 7, 6, 4, 2], [47, 7, 7, 4, 2], [48, 7, 8, 4, 2], [49, 7, 9, 3, 2], [50, 7, 10, 3, 2],
		[51, 7, 11, 3, 2], [52, 7, 12, 3, 2], [53, 7, 13, 3, 2], [54, 7, 14, 3, 2], [55, 7, 15, 3, 2],
		[56, 7, 16, 3, 1], [57, 7, 17, 3, 1], [58, 7, 18, 3, 1], [59, 7, 19, 3, 1], [60, 7, 20, 3, 1],
		[61, 7, 21, 3, 1], [62, 7, 22, 3, 1], [63, 7, 23, 2, 1], [64, 7, 24, 2, 1], [65, 7, 25, 2, 1],
		[66, 7, 26, 2, 1], [67, 7, 27, 2, 1], [68, 7, 28, 2, 1], [69, 7, 29, 2, 1], [70, 7, 30, 2, 1],
		[71, 8, 1, 5, 2], [72, 8, 2, 5, 2], [73, 8, 3, 5, 2], [74, 8, 4, 5, 2], [75, 8, 5, 5, 2],
		[76, 8, 6, 5, 2], [77, 8, 7, 5, 2], [78, 8, 8, 5, 2], [79, 8, 9, 5, 2], [80, 8, 10, 5, 2],
		[81, 8, 11, 5, 2], [82, 8, 12, 5, 2], [83, 8, 13, 5, 2], [84, 8, 14, 5, 2], [85, 8, 15, 5, 2],
		[86, 8, 16, 4, 2], [87, 8, 17, 4, 2], [88, 8, 18, 4, 2], [89, 8, 19, 4, 2], [90, 8, 20, 4, 2],
		[91, 8, 21, 4, 2], [92, 8, 22, 4, 2], [93, 8, 23, 4, 2], [94, 8, 24, 4, 2], [95, 8, 25, 4, 2],
		[96, 8, 26, 4, 2], [97, 8, 27, 4, 2], [98, 8, 28, 4, 2], [99, 8, 29, 4, 2], [100, 8, 30, 4, 2]
	]
	assert_eq(LevelPack.GENERATED_SPECS, expected)


## CHECK: 2
func test_load_default_levels_size_and_new_levels() -> void:
	var levels = Session.load_default_levels()
	assert_eq(levels.size(), 100)
	for i in range(70, 100):
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
	assert_eq(dicts.size(), 100)
	for i in range(70, 100):
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
	s.restore_dict({"level_index": 69, "score": 0, "hints": 3})
	s.next_level()
	assert_eq(s.level_index, 70)
	assert_eq(s.level.id, 71)
	assert_eq(s.level.width, 8)
	assert_eq(Solver.count_solutions(s.level, 2), 1)
