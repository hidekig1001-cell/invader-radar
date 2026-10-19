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
		[21, 7, 6], [22, 7, 7], [23, 7, 8], [24, 7, 9], [25, 7, 10]
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
	assert_eq(levels.size(), 25)
	for i in range(15, 25):
		var lv = levels[i]
		assert_eq(lv.id, i + 1)
		assert_eq(lv.width, 7)
		assert_eq(lv.height, 7)
		assert_eq(lv.target, 7)
		var expected_rows = [
			"0000000", "1111111", "2222222", "3333333", "4444444", "5555555", "6666666"
		]
		assert_eq(lv.regions.to_rows(), expected_rows)


## CHECK: 4
func test_level_dicts_placeholder() -> void:
	var dicts = LevelPack.level_dicts()
	assert_eq(dicts.size(), 25)
	for i in range(15, 25):
		var d = dicts[i]
		assert_eq(d["id"], i + 1)
		assert_eq(d["width"], 7)
		assert_eq(d["height"], 7)
		assert_eq(d["target"], 7)
		var lv = Level.new()
		assert_true(lv.parse(d))
		assert_eq(Solver.count_solutions(lv, 2), 1)


## CHECK: 5
func test_session_next_level_placeholder() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 14, "score": 0, "hints": 3})
	s.next_level()
	assert_eq(s.level_index, 15)
	assert_eq(s.level.id, 16)
	assert_eq(s.level.width, 7)
	assert_eq(Solver.count_solutions(s.level, 2), 1)
