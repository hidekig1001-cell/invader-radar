extends GutTest

func test_cr_1192_radar_cell_skipped_in_row() -> void:
	## CHECK: 1
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"radar": [[0, 0, 1]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_cr_1192_asteroid_skipped_in_row() -> void:
	## CHECK: 2
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"asteroids": [[3, 3]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	
	b.apply("place", 1, 3)
	result = Rules.dead_marks(b, level)
	assert_eq(result, [])


func test_cr_1192_radar_cell_skipped_in_region_and_col() -> void:
	## CHECK: 3
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"radar": [[0, 0, 1]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	
	result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)])
