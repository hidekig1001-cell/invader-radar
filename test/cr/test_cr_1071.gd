extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")

## CHECK: 1
func test_generated_specs_content() -> void:
	var expected = [
		[11, 5, 1, 5, 3], [12, 5, 2, 5, 3], [13, 5, 3, 5, 3], [14, 5, 4, 5, 3], [15, 5, 5, 4, 3],
		[16, 5, 6, 4, 3], [17, 5, 7, 4, 2], [18, 5, 8, 4, 2], [19, 5, 9, 3, 2], [20, 5, 10, 3, 2],
		[21, 6, 1, 6, 4], [22, 6, 2, 6, 4], [23, 6, 3, 6, 4], [24, 6, 4, 6, 4], [25, 6, 5, 6, 4],
		[26, 6, 6, 5, 3], [27, 6, 7, 5, 3], [28, 6, 8, 5, 3], [29, 6, 9, 5, 3], [30, 6, 10, 5, 3],
		[31, 6, 11, 4, 3], [32, 6, 12, 4, 3], [33, 6, 13, 4, 3], [34, 6, 14, 4, 3], [35, 6, 15, 4, 3],
		[36, 6, 16, 3, 2], [37, 6, 17, 3, 2], [38, 6, 18, 3, 2], [39, 6, 19, 3, 2], [40, 6, 20, 3, 2],
		[41, 7, 1, 7, 4], [42, 7, 2, 7, 4], [43, 7, 3, 7, 4], [44, 7, 4, 7, 4], [45, 7, 5, 7, 4],
		[46, 7, 6, 7, 4], [47, 7, 7, 6, 4], [48, 7, 8, 6, 4], [49, 7, 9, 6, 4], [50, 7, 10, 6, 4],
		[51, 7, 11, 6, 3], [52, 7, 12, 6, 3], [53, 7, 13, 5, 3], [54, 7, 14, 5, 3], [55, 7, 15, 5, 3],
		[56, 7, 16, 5, 3], [57, 7, 17, 5, 3], [58, 7, 18, 5, 3], [59, 7, 19, 4, 3], [60, 7, 20, 4, 3],
		[61, 7, 21, 4, 2], [62, 7, 22, 4, 2], [63, 7, 23, 4, 2], [64, 7, 24, 4, 2], [65, 7, 25, 3, 2],
		[66, 7, 26, 3, 2], [67, 7, 27, 3, 2], [68, 7, 28, 3, 2], [69, 7, 29, 3, 2], [70, 7, 30, 3, 2],
		[71, 8, 1, 8, 4], [72, 8, 2, 8, 4], [73, 8, 3, 8, 4], [74, 8, 4, 8, 4], [75, 8, 5, 8, 4],
		[76, 8, 6, 8, 4], [77, 8, 7, 7, 4], [78, 8, 8, 7, 4], [79, 8, 9, 7, 4], [80, 8, 10, 7, 4],
		[81, 8, 11, 7, 3], [82, 8, 12, 7, 3], [83, 8, 13, 6, 3], [84, 8, 14, 6, 3], [85, 8, 15, 6, 3],
		[86, 8, 16, 6, 3], [87, 8, 17, 6, 3], [88, 8, 18, 6, 3], [89, 8, 19, 5, 3], [90, 8, 20, 5, 3],
		[91, 8, 21, 5, 2], [92, 8, 22, 5, 2], [93, 8, 23, 5, 2], [94, 8, 24, 5, 2], [95, 8, 25, 4, 2],
		[96, 8, 26, 4, 2], [97, 8, 27, 4, 2], [98, 8, 28, 4, 2], [99, 8, 29, 4, 2], [100, 8, 30, 4, 2]
	]
	assert_eq(LevelPack.GENERATED_SPECS, expected)

## CHECK: 2
func test_level_dicts_content_and_solutions() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 100)
	for i in range(10, 100):
		var d = dicts[i]
		var spec = LevelPack.GENERATED_SPECS[i - 10]
		assert_eq(d.get("id"), i + 1)
		assert_eq(d.get("width"), spec[1])
		assert_eq(d.get("height"), spec[1])
		assert_eq(d.get("target"), spec[1])
		assert_eq(d.get("radar", []).size(), spec[3])
		assert_eq(d.get("asteroids", []).size(), spec[4])
		
		var level = Level.new()
		assert_true(level.parse(d))
		assert_eq(Solver.count_solutions(level, 2), 1)

## CHECK: 3
func test_session_restore_dict_level_21_and_100() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 20, "score": 0, "hints": 3})
	assert_eq(s.level.id, 21)
	assert_eq(s.level.width, 6)
	assert_eq(s.level.radar.size(), 6)
	assert_eq(s.level.asteroids.size(), 4)
	assert_eq(Solver.count_solutions(s.level, 2), 1)

	var s2 = Session.new()
	s2.rng.seed = 1
	s2.restore_dict({"level_index": 99, "score": 0, "hints": 3})
	assert_eq(s2.level.id, 100)
	assert_eq(s2.level.width, 8)
	assert_eq(s2.level.radar.size(), 4)
	assert_eq(s2.level.asteroids.size(), 2)
	assert_eq(Solver.count_solutions(s2.level, 2), 1)
