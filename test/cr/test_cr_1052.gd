extends GutTest

const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")
const Rules = preload("res://core/rules.gd")
const LevelPack = preload("res://game/level_pack.gd")

# CHECK: 1
func test_pick_radar_returns_1_or_2_items() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 7
	var solution = [2, 4, 0, 3, 5, 1]
	var result = LevelMaker.pick_radar(rng, solution)
	assert_true(result.size() == 1 or result.size() == 2)
	assert_false(result.is_empty())

# CHECK: 2
func test_pick_radar_does_not_select_piece_cells() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 7
	var solution = [2, 4, 0, 3, 5, 1]
	var result = LevelMaker.pick_radar(rng, solution)
	for item in result:
		var x = item[0]
		var y = item[1]
		assert_ne(x, solution[y])

# CHECK: 3
func test_pick_radar_count_matches_rules() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 7
	var solution = [2, 4, 0, 3, 5, 1]
	var result = LevelMaker.pick_radar(rng, solution)
	var pieces = []
	for y in range(solution.size()):
		pieces.append(Vector2i(solution[y], y))
	for item in result:
		var x = item[0]
		var y = item[1]
		var n = item[2]
		var expected_n = Rules.radar_count(pieces, x, y)
		assert_eq(n, expected_n)

# CHECK: 4
func test_pick_radar_is_deterministic() -> void:
	var rng1 = RandomNumberGenerator.new()
	rng1.seed = 7
	var solution = [2, 4, 0, 3, 5, 1]
	var result1 = LevelMaker.pick_radar(rng1, solution)

	var rng2 = RandomNumberGenerator.new()
	rng2.seed = 7
	var result2 = LevelMaker.pick_radar(rng2, solution)

	assert_false(result1.is_empty())
	assert_eq(result1, result2)

# CHECK: 5
func test_make_level_has_valid_radar_structure() -> void:
	var level_dict = LevelMaker.make_level(6, 6, 1)
	assert_true(level_dict.has("radar"))
	var radar = level_dict["radar"]
	assert_true(radar.size() == 1 or radar.size() == 2)
	for item in radar:
		assert_eq(item.size(), 3)

# CHECK: 6
func test_make_level_radar_is_deterministic() -> void:
	var dict1 = LevelMaker.make_level(6, 6, 1)
	var dict2 = LevelMaker.make_level(6, 6, 1)
	assert_true(dict1.has("radar"))
	assert_false(dict1["radar"].is_empty())
	assert_eq(dict1["radar"], dict2["radar"])

# CHECK: 7
func test_make_level_radar_cells_not_in_solution() -> void:
	var level_dict = LevelMaker.make_level(6, 6, 1)
	var level = Level.new()
	assert_true(level.parse(level_dict))
	var solutions = Solver.solutions(level, 1)
	assert_false(solutions.is_empty())
	var solution_pieces = solutions[0] # Array of Vector2i
	
	var radar = level_dict["radar"]
	for item in radar:
		var x = item[0]
		var y = item[1]
		var found = false
		for piece in solution_pieces:
			if piece.x == x and piece.y == y:
				found = true
				break
		assert_false(found)

# CHECK: 8
func test_make_level_radar_count_matches_solution() -> void:
	var level_dict = LevelMaker.make_level(6, 6, 1)
	var level = Level.new()
	assert_true(level.parse(level_dict))
	var solutions = Solver.solutions(level, 1)
	assert_false(solutions.is_empty())
	var solution_pieces = solutions[0] # Array of Vector2i
	
	var radar = level_dict["radar"]
	for item in radar:
		var x = item[0]
		var y = item[1]
		var n = item[2]
		var expected_n = Rules.radar_count(solution_pieces, x, y)
		assert_eq(n, expected_n)

# CHECK: 9
func test_level_pack_11_13_have_radar() -> void:
	var dicts = LevelPack.level_dicts()
	var ids_to_check = [11, 12, 13]
	for id in ids_to_check:
		var dict = null
		for d in dicts:
			if d["id"] == id:
				dict = d
				break
		assert_not_null(dict)
		
		var level = Level.new()
		assert_true(level.parse(dict))
		assert_eq(Solver.count_solutions(level, 2), 1)
		
		assert_true(dict.has("radar"))
		var radar = dict["radar"]
		assert_true(radar.size() == 5)
