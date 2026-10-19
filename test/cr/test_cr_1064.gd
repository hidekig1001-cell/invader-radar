extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_make_level_8x8_has_3_to_5_radar_and_unique_solution() -> void:
	for s in range(1, 21):
		var level_dict = LevelMaker.make_level(8, 8, s)
		assert_false(level_dict.is_empty(), "make_level returned empty for seed %d" % s)
		
		var radar = level_dict.get("radar", [])
		assert_true(radar.size() >= 3 and radar.size() <= 5, "Radar count out of range [3,5] for seed %d: got %d" % [s, radar.size()])
		
		for r in radar:
			assert_eq(r.size(), 3, "Radar entry malformed for seed %d" % s)
			var x = r[0]
			var y = r[1]
			var n = r[2]
			assert_true(x >= 0 and x < 8, "Radar x out of bounds for seed %d" % s)
			assert_true(y >= 0 and y < 8, "Radar y out of bounds for seed %d" % s)
			assert_true(n >= 0, "Radar count negative for seed %d" % s)
			
		var level = Level.new()
		var parsed = level.parse(level_dict)
		assert_true(parsed, "Level parse failed for seed %d" % s)
		
		var solutions_count = Solver.count_solutions(level, 2)
		assert_eq(solutions_count, 1, "Solution count not unique for seed %d: got %d" % [s, solutions_count])


## CHECK: 2
func test_pick_radar_8x8_returns_3_to_5_items() -> void:
	var solution = [0, 2, 4, 6, 1, 3, 5, 7]
	for seed in range(1, 11):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		var radar = LevelMaker.pick_radar(rng, solution)
		
		assert_true(radar.size() >= 3 and radar.size() <= 5, "pick_radar size out of range [3,5] for seed %d: got %d" % [seed, radar.size()])
		
		for r in radar:
			var x = r[0]
			var y = r[1]
			assert_true(x >= 0 and x < 8, "Radar x out of bounds")
			assert_true(y >= 0 and y < 8, "Radar y out of bounds")
			# Check that radar cell is not a solution piece cell
			# solution[y] gives the x coordinate of the piece at row y
			assert_ne(x, solution[y], "Radar cell (%d,%d) overlaps with solution piece" % [x, y])


## CHECK: 2
func test_pick_radar_6x6_returns_1_or_2_items() -> void:
	var solution = [2, 4, 0, 3, 5, 1]
	for seed in range(1, 11):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		var radar = LevelMaker.pick_radar(rng, solution)
		
		assert_true(radar.size() >= 1 and radar.size() <= 2, "pick_radar size out of range [1,2] for seed %d: got %d" % [seed, radar.size()])
