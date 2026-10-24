extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_generated_specs() -> void:
	var expected = [
		[11, 5, 1, 4, 3], [12, 5, 2, 4, 3], [13, 5, 3, 4, 3], [14, 5, 4, 3, 2], [15, 5, 5, 3, 2],
		[16, 5, 6, 3, 2], [17, 5, 7, 2, 2], [18, 5, 8, 2, 1], [19, 5, 9, 2, 1], [20, 5, 10, 1, 1],
		[21, 6, 1, 5, 3], [22, 6, 2, 5, 3], [23, 6, 3, 5, 3], [24, 6, 4, 5, 3], [25, 6, 5, 4, 3],
		[26, 6, 6, 4, 3], [27, 6, 7, 4, 2], [28, 6, 8, 4, 2], [29, 6, 9, 3, 2], [30, 6, 10, 3, 2],
		[31, 6, 11, 3, 2], [32, 6, 12, 3, 2], [33, 6, 13, 2, 2], [34, 6, 14, 2, 2], [35, 6, 15, 2, 1],
		[36, 6, 16, 2, 1], [37, 6, 17, 2, 1], [38, 6, 18, 1, 1], [39, 6, 19, 1, 1], [40, 6, 20, 1, 1],
		[41, 7, 1, 6, 4], [42, 7, 2, 6, 4], [43, 7, 3, 6, 4], [44, 7, 4, 6, 4], [45, 7, 5, 6, 4],
		[46, 7, 6, 5, 4], [47, 7, 7, 5, 3], [48, 7, 8, 5, 3], [49, 7, 9, 5, 3], [50, 7, 10, 5, 3],
		[51, 7, 11, 4, 3], [52, 7, 12, 4, 3], [53, 7, 13, 4, 3], [54, 7, 14, 4, 3], [55, 7, 15, 4, 2],
		[56, 7, 16, 3, 2], [57, 7, 17, 3, 2], [58, 7, 18, 3, 2], [59, 7, 19, 3, 2], [60, 7, 20, 3, 2],
		[61, 7, 21, 3, 2], [62, 7, 22, 3, 2], [63, 7, 23, 2, 2], [64, 7, 24, 2, 2], [65, 7, 25, 2, 1],
		[66, 7, 26, 2, 1], [67, 7, 27, 2, 1], [68, 7, 28, 2, 1], [69, 7, 29, 2, 1], [70, 7, 30, 2, 1],
		[71, 8, 1, 7, 4], [72, 8, 2, 7, 4], [73, 8, 3, 7, 4], [74, 8, 4, 7, 4], [75, 8, 5, 7, 4],
		[76, 8, 6, 6, 4], [77, 8, 7, 6, 4], [78, 8, 8, 6, 4], [79, 8, 9, 6, 3], [80, 8, 10, 6, 3],
		[81, 8, 11, 5, 3], [82, 8, 12, 5, 3], [83, 8, 13, 5, 3], [84, 8, 14, 5, 3], [85, 8, 15, 5, 3],
		[86, 8, 16, 5, 3], [87, 8, 17, 5, 2], [88, 8, 18, 5, 2], [89, 8, 19, 5, 2], [90, 8, 20, 5, 2],
		[91, 8, 21, 4, 2], [92, 8, 22, 4, 2], [93, 8, 23, 4, 2], [94, 8, 24, 4, 2], [95, 8, 25, 4, 2],
		[96, 8, 26, 4, 2], [97, 8, 27, 4, 2], [98, 8, 28, 4, 2], [99, 8, 29, 4, 2], [100, 8, 30, 4, 2]
	]
	assert_eq(LevelPack.GENERATED_SPECS, expected)


## CHECK: 2
func test_placeholder_regions() -> void:
	var expected = [
		[0, 0, 0, 0, 0, 0, 0],
		[1, 1, 1, 1, 1, 1, 1],
		[2, 2, 2, 2, 2, 2, 2],
		[3, 3, 3, 3, 3, 3, 3],
		[4, 4, 4, 4, 4, 4, 4],
		[5, 5, 5, 5, 5, 5, 5],
		[6, 6, 6, 6, 6, 6, 6]
	]
	assert_eq(Session.placeholder_regions(7), expected)


## CHECK: 3
func test_load_default_levels_placeholder() -> void:
	var levels = Session.load_default_levels()
	assert_eq(levels.size(), 100)
	for i in range(40, 70):
		var lv = levels[i]
		assert_eq(lv.id, i + 1)
		assert_eq(lv.width, 7)
		assert_eq(lv.height, 7)
		assert_eq(lv.target, 7)
		var expected_rows = [
			"0000000", "1111111", "2222222", "3333333", "4444444", "5555555", "6666666"
		]
		assert_eq(lv.regions.to_rows(), expected_rows)
	for i in range(70, 100):
		var lv = levels[i]
		assert_eq(lv.id, i + 1)
		assert_eq(lv.width, 8)
		assert_eq(lv.height, 8)
		assert_eq(lv.target, 8)
		var expected_rows = [
			"00000000", "11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777"
		]
		assert_eq(lv.regions.to_rows(), expected_rows)


## CHECK: 4
func test_level_dicts_placeholder() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 100)
	for i in range(40, 70):
		var d = dicts[i]
		assert_eq(d["id"], i + 1)
		assert_eq(d["width"], 7)
		assert_eq(d["height"], 7)
		assert_eq(d["target"], 7)
		var lv = Level.new()
		assert_true(lv.parse(d))
		assert_eq(Solver.count_solutions(lv, 2), 1)
	for i in range(70, 100):
		var d = dicts[i]
		assert_eq(d["id"], i + 1)
		assert_eq(d["width"], 8)
		assert_eq(d["height"], 8)
		assert_eq(d["target"], 8)
		var lv = Level.new()
		assert_true(lv.parse(d))
		assert_eq(Solver.count_solutions(lv, 2), 1)


## CHECK: 5
func test_session_next_level_placeholder() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 39, "score": 0, "hints": 3})
	s.next_level()
	assert_eq(s.level_index, 40)
	assert_eq(s.level.id, 41)
	assert_eq(s.level.width, 7)
	assert_eq(Solver.count_solutions(s.level, 2), 1)
