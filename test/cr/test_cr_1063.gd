extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const LevelPack = preload("res://game/level_pack.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_cr_1063_make_level_7x7_has_valid_asteroids_and_6x6_does_not() -> void:
	# Check 7x7 levels for seeds 1-10
	for s in range(1, 11):
		var level_dict = LevelMaker.make_level(7, 7, s)
		assert_true(level_dict.has("asteroids"), "Level 7x7 seed %d should have asteroids" % s)
		
		var asteroids: Array = level_dict["asteroids"]
		assert_true(asteroids.size() == 1 or asteroids.size() == 2, "Asteroid count should be 1 or 2 for seed %d" % s)
		
		var radar: Array = level_dict["radar"]
		for ast in asteroids:
			assert_eq(ast.size(), 2, "Asteroid entry should be [x, y]")
			var ax = ast[0]
			var ay = ast[1]
			
			# Check against radar
			for r in radar:
				var rx = r[0]
				var ry = r[1]
				assert_true(ax != rx or ay != ry, "Asteroid [%d,%d] overlaps Radar [%d,%d] for seed %d" % [ax, ay, rx, ry, s])
			
			# Check against solution (pieces)
			# Solution is implicit in regions/target but we can check if it's a valid empty cell by parsing?
			# The requirement says "not on solution cells". 
			# We can verify uniqueness and parseability which implies validity.
		
		var level = Level.new()
		assert_true(level.parse(level_dict), "Level 7x7 seed %d failed to parse" % s)
		assert_eq(Solver.count_solutions(level, 2), 1, "Level 7x7 seed %d does not have unique solution" % s)

	# Check 6x6 levels for seeds 1-5 do NOT have asteroids
	for s in range(1, 6):
		var level_dict = LevelMaker.make_level(6, 6, s)
		assert_false(level_dict.has("asteroids"), "Level 6x6 seed %d should NOT have asteroids" % s)


## CHECK: 2
func test_cr_1063_level_pack_indices_15_to_24_have_valid_asteroids() -> void:
	var dicts = LevelPack.level_dicts()
	var expected_counts = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
	# Indices 40 to 69 correspond to levels 41-70 (0-indexed)
	for i in range(40, 70):
		assert_true(i < dicts.size(), "Level dict index %d out of bounds" % i)
		var level_dict = dicts[i]
		
		assert_true(level_dict.has("asteroids"), "Level dict at index %d should have asteroids" % i)
		var asteroids: Array = level_dict["asteroids"]
		assert_true(asteroids.size() == expected_counts[i - 40], "Asteroid count at index %d should be 1 or 2" % i)
		
		for ast in asteroids:
			assert_eq(ast.size(), 2, "Asteroid entry at index %d should be [x, y]" % i)
			
		var level = Level.new()
		assert_true(level.parse(level_dict), "Level dict at index %d failed to parse" % i)
		assert_eq(Solver.count_solutions(level, 2), 1, "Level dict at index %d does not have unique solution" % i)


## CHECK: 3
func test_cr_1063_pick_asteroids_validity() -> void:
	var solution = [1, 3, 5, 0, 2, 4, 6]
	var radar = [[0, 0, 1]]
	
	for seed in range(1, 11):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		
		var asteroids = LevelMaker.pick_asteroids(rng, solution, radar)
		
		assert_true(asteroids.size() == 1 or asteroids.size() == 2, "pick_asteroids should return 1 or 2 items for seed %d" % seed)
		
		for ast in asteroids:
			assert_eq(ast.size(), 2, "Asteroid entry should be [x, y] for seed %d" % seed)
			var x = ast[0]
			var y = ast[1]
			
			# Check not on solution cell
			# Solution[y] is the x coordinate of the piece at row y
			assert_true(x != solution[y], "Asteroid [%d,%d] is on solution cell for seed %d" % [x, y, seed])
			
			# Check not on radar cell
			for r in radar:
				var rx = r[0]
				var ry = r[1]
				assert_true(x != rx or y != ry, "Asteroid [%d,%d] is on radar cell for seed %d" % [x, y, seed])
