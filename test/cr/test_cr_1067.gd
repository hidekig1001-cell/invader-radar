extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_make_level_6x6_with_radar3_asteroids2() -> void:
	for s in range(1, 11):
		var level_dict = LevelMaker.make_level(6, 6, s, 3, 2)
		
		assert_true(level_dict.has("radar"))
		var radar = level_dict["radar"]
		assert_eq(radar.size(), 3)
		
		assert_true(level_dict.has("asteroids"))
		var asteroids = level_dict["asteroids"]
		assert_eq(asteroids.size(), 2)
		
		for a in asteroids:
			for r in radar:
				assert_false(a[0] == r[0] and a[1] == r[1])
				
		var level = Level.new()
		assert_true(level.parse(level_dict))
		assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 2
func test_make_level_5x5_with_radar0_asteroids0() -> void:
	for s in range(1, 11):
		var level_dict = LevelMaker.make_level(5, 5, s, 0, 0)
		
		assert_true(level_dict.has("radar"))
		var radar = level_dict["radar"]
		assert_eq(radar.size(), 0)
		
		assert_false(level_dict.has("asteroids"))
		
		var level = Level.new()
		assert_true(level.parse(level_dict))
		assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 3
func test_make_level_8x8_with_radar4_asteroids2() -> void:
	for s in range(1, 6):
		var level_dict = LevelMaker.make_level(8, 8, s, 4, 2)
		
		assert_true(level_dict.has("radar"))
		var radar = level_dict["radar"]
		assert_eq(radar.size(), 4)
		
		assert_true(level_dict.has("asteroids"))
		var asteroids = level_dict["asteroids"]
		assert_eq(asteroids.size(), 2)
		
		var level = Level.new()
		assert_true(level.parse(level_dict))
		assert_eq(Solver.count_solutions(level, 2), 1)


## CHECK: 4
func test_pick_radar_and_asteroids_with_count_args() -> void:
	for seed in range(1, 11):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		
		var solution = [1, 3, 0, 2]
		
		var radar = LevelMaker.pick_radar(rng, solution, 3)
		assert_eq(radar.size(), 3)
		
		var asteroids = LevelMaker.pick_asteroids(rng, solution, [[0, 0, 1]], 2)
		assert_eq(asteroids.size(), 2)
		
		for a in asteroids:
			var x = a[0]
			var y = a[1]
			assert_ne(x, solution[y])
			assert_false(x == 0 and y == 0)
