extends GutTest

const Rules = preload("res://core/rules.gd")
const Level = preload("res://game/level.gd")
const BS = preload("res://core/board_state.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")

## CHECK: 1
func test_dead_marks_basic() -> void:
	var l = Level.new()
	l.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})

	# Case 1: Partial marks in region 0 -> empty result
	var b = BS.new(4, 4)
	b.apply("mark", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	assert_eq(Rules.dead_marks(b, l), [])

	# Case 2: Full marks in region 0 -> all marks in region 0
	b.apply("mark", 1, 1)
	var expected_region = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
	assert_eq(Rules.dead_marks(b, l), expected_region)

	# Case 3: Full marks in row 0 -> all marks in row 0
	var b2 = BS.new(4, 4)
	b2.apply("mark", 0, 0)
	b2.apply("mark", 1, 0)
	b2.apply("mark", 2, 0)
	b2.apply("mark", 3, 0)
	var expected_row = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	assert_eq(Rules.dead_marks(b2, l), expected_row)

	# Case 4: Asteroid blocks region completion
	var l2 = Level.new()
	l2.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [[1, 1]]
	})
	var b3 = BS.new(4, 4)
	b3.apply("mark", 0, 0)
	b3.apply("mark", 1, 0)
	b3.apply("mark", 0, 1)
	# Region 0 has cells (0,0), (1,0), (0,1), (1,1). (1,1) is asteroid.
	# Remaining cells (0,0), (1,0), (0,1) are all marked.
	var expected_asteroid = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	assert_eq(Rules.dead_marks(b3, l2), expected_asteroid)

	# Case 5: Alien in row prevents dead marks
	var b4 = BS.new(4, 4)
	b4.apply("place", 0, 0) # Alien at (0,0)
	b4.apply("mark", 1, 0)
	b4.apply("mark", 2, 0)
	b4.apply("mark", 3, 0)
	# Row 0 has an alien, so it's not "dead" even if other cells are marked.
	assert_eq(Rules.dead_marks(b4, l), [])

## CHECK: 2
func test_mark_color_at_dead_marks() -> void:
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})
	var s = SessionScript.new([level])
	s.board.apply("mark", 0, 0)
	s.board.apply("mark", 1, 0)
	s.board.apply("mark", 0, 1)
	s.board.apply("mark", 1, 1)
	s.board.apply("mark", 3, 3)

	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s

	# (0,0) is part of a dead region (Region 0 is fully marked) -> RED
	assert_eq(bv.mark_color_at(0, 0), Color.RED)

	# (3,3) is in Region 3. Region 3 cells: (2,2), (3,2), (2,3), (3,3).
	# Only (3,3) is marked. Not all non-asteroid/non-alien cells are marked.
	# So it should be normal MARK_COLOR.
	assert_true(bv.mark_color_at(3, 3).is_equal_approx(Color(0.25, 0.22, 0.40)))
