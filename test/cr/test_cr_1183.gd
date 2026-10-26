extends GutTest

const Level = preload("res://game/level.gd")
const Rules = preload("res://core/rules.gd")
const BS = preload("res://core/board_state.gd")


func _make_level() -> Level:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		]
	})
	return level


## CHECK: 1
func test_cr_1183_row_incomplete_then_complete() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	assert_eq(Rules.filled_lines(b, level), [])
	
	b.apply("mark", 3, 0)
	assert_eq(Rules.filled_lines(b, level), [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}])


## CHECK: 2
func test_cr_1183_multiple_aliens_or_no_alien() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Row 0 has 2 aliens
	b.apply("place", 0, 0)
	b.apply("place", 2, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 3, 0)
	
	# Row 3 has only marks (0 aliens)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	
	assert_eq(Rules.filled_lines(b, level), [])
	
	# Change (2, 0) from alien to mark. Now Row 0 has 1 alien and 3 marks.
	b.apply("mark", 2, 0)
	
	assert_eq(Rules.filled_lines(b, level), [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}])


## CHECK: 3
func test_cr_1183_conflicting_alien() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Place aliens at (0, 0) and (0, 2). They are in the same column, so they conflict.
	b.apply("place", 0, 0)
	b.apply("place", 0, 2)
	
	# Fill row 0 with marks except for the alien at (0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	# Row 0 has an alien that is in conflict, so it should not be returned.
	assert_eq(Rules.filled_lines(b, level), [])
	
	# Clear the conflicting alien at (0, 2). Now (0, 0) is no longer in conflict with another alien.
	b.apply("clear", 0, 2)
	
	assert_eq(Rules.filled_lines(b, level), [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}])


## CHECK: 4
func test_cr_1183_region_and_ordering() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Fill region 0: (0,0) alien, others marks
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	
	assert_eq(Rules.filled_lines(b, level), [{"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}])
	
	# Now fill row 0 and column 0 completely.
	# Row 0: (0,0) is alien, (1,0) mark, need (2,0) and (3,0) marks.
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	# Column 0: (0,0) is alien, (0,1) mark, need (0,2) and (0,3) marks.
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	
	assert_eq(Rules.filled_lines(b, level), [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}, {"kind": "column", "index": 0, "cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]}, {"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}])


## CHECK: 5
func test_cr_1183_asteroids_and_radar_excluded() -> void:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		],
		"asteroids": [[3, 0]],
		"radar": [[2, 0, 1]]
	})
	var b = BS.new(4, 4)
	
	b.apply("mark", 0, 0)
	b.apply("place", 1, 0)
	
	assert_eq(Rules.filled_lines(b, level), [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}])
