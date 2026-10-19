extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")

## CHECK: 1
func test_grow_regions_8x8_no_minus_one() -> void:
	var solution = [0, 2, 4, 6, 1, 3, 5, 7]
	for seed in range(1, 21):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		var grid = LevelMaker.grow_regions(rng, 8, solution)
		
		assert_eq(grid.size(), 8, "Grid should have 8 rows")
		for y in range(8):
			assert_eq(grid[y].size(), 8, "Row %d should have 8 columns" % y)
			for x in range(8):
				var val = grid[y][x]
				assert_true(val >= 0 and val <= 7, "Cell (%d,%d) value %d is out of range [0,7]" % [x, y, val])
			
			# Check that the solution cells retain their original region index
			var expected_val = solution[y]
			assert_eq(grid[y][expected_val], y, "Solution cell at row %d should have value %d" % [y, y])

## CHECK: 1
func test_grow_regions_5x5_no_minus_one() -> void:
	var solution = [0, 2, 4, 1, 3]
	for seed in range(1, 21):
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		var grid = LevelMaker.grow_regions(rng, 5, solution)
		
		assert_eq(grid.size(), 5, "Grid should have 5 rows")
		for y in range(5):
			assert_eq(grid[y].size(), 5, "Row %d should have 5 columns" % y)
			for x in range(5):
				var val = grid[y][x]
				assert_true(val >= 0 and val <= 4, "Cell (%d,%d) value %d is out of range [0,4]" % [x, y, val])
