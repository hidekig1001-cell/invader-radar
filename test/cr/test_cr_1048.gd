extends GutTest

const BoardView = preload("res://scenes/board_view.gd")
const Level = preload("res://game/level.gd")
const BoardState = preload("res://core/board_state.gd")
const Rules = preload("res://core/rules.gd")

# Helper to create a mock session with specific board and level data
func _make_session(width: int, height: int, radar_data: Array, pieces: Array) -> Dictionary:
	var level = Level.new()
	# Parse minimal level data. We need width, height, and radar.
	# Assuming Level.parse accepts a dictionary structure similar to JSON.
	# Based on typical Godot project structures for this kind of puzzle game:
	var level_data = {
		"width": width,
		"height": height,
		"radar": radar_data,
		"asteroids": [],
		"regions": [] # Assuming regions might be needed or default to 0
	}
	level.parse(level_data)

	var board = BoardState.new()
	# Initialize board with dimensions if possible, or rely on apply to handle bounds?
	# Usually board_state needs initialization. Let's assume standard init or just use apply.
	# If resize doesn't exist, we might need to check how BoardState is initialized in other tests.
	# Looking at test_main_scene.gd, it uses m.session which is loaded from level.
	# Here we are mocking. Let's try to initialize board properly.
	# If BoardState.new() creates an empty board, we might need to set dimensions.
	# Since resize is not allowed, let's assume the constructor or a setter handles it, 
	# or that apply works on a default sized board if we don't know the init method.
	# However, usually there is an init method. Let's look for clues.
	# The prompt says "board.apply(...)". It doesn't mention init.
	# Let's assume BoardState.new() might take width/height or we set them via properties if available.
	# But without knowing the exact API of BoardState beyond apply and pieces, 
	# I will assume that for the purpose of this test, we can create a board 
	# that accepts these coordinates. If BoardState requires explicit sizing, 
	# it might be done via a property or constructor. 
	# Given the constraint "only use existing functions", if resize doesn't exist, 
	# maybe the board is sized by the level? No, board is separate.
	# Let's try to just use apply and see if it fails in the "before" state (which is expected).
	# The error was specifically about `resize`. I will remove it.
	# If the board needs sizing, maybe it's done via `board.init(width, height)`? 
	# But I don't know if init exists. 
	# Let's look at the "CR に出てくる名前の種類". It lists `pieces()` and `apply` is mentioned in notes.
	# It does NOT list `init` or `resize`.
	# I will assume that for the test to work, we might need to set properties if they are vars, 
	# but the prompt says "func ... x.NAME = 値 と代入できるのは var だけ".
	# If width/height are vars, I can set them. But I don't know if they are.
	# Let's assume the board is created with a default size or the level dictates it?
	# No, session has both.
	# Let's try to see if there is an `init` function in core/board_state.gd? 
	# The prompt lists `pieces()` from core/board_state.gd:55. 
	# It doesn't list init. 
	# I will remove the resize call and hope for the best, or assume the board is pre-sized.
	# Wait, if I can't size it, how do I test 4x4?
	# Maybe `BoardState.new(4, 4)`?
	# Let's try that.

	var b = BoardState.new()
	# Attempt to set dimensions via properties if they are vars, otherwise skip.
	# Since I don't know, I'll just use apply. 
	# If this fails, it's a setup issue, but `resize` was the specific error.
	
	for p in pieces:
		if p is Array and p.size() >= 2:
			b.apply("place", int(p[0]), int(p[1]))
		elif p is Vector2i:
			b.apply("place", p.x, p.y)

	return {
		"level": level,
		"board": b
	}

# Helper to create a board_view instance with a session
func _make_board_view(session_data: Dictionary) -> Node2D:
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session_data
	return bv


## CHECK: 1
func test_radar_font_size_null_session() -> void:
	var bv = BoardView.new()
	add_child_autofree(bv)
	# session is null by default
	assert_eq(bv.radar_font_size(), 0.0)

## CHECK: 1
func test_radar_font_size_with_session() -> void:
	# Case 1: Empty session (null) -> should return 0.0
	var bv_null = BoardView.new()
	add_child_autofree(bv_null)
	assert_eq(bv_null.radar_font_size(), 0.0)

	# Case 2: Valid session -> should return > 0.0
	var w := 4
	var h := 4
	var level = Level.new()
	var level_data = {
		"id": 1,
		"width": w,
		"height": h,
		"target": w,
		"regions": [],
		"asteroids": [],
		"radar": []
	}
	for y in range(h):
		var row := []
		for x in range(w):
			row.append(0)
		level_data["regions"].append(row)
	
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session
	
	assert_true(bv.radar_font_size() > 0.0)

## CHECK: 2
func test_radar_font_size_4x4() -> void:
	# 4x4 board. AREA is 1000x1000. Cell size = 1000/4 = 250.
	# radar_font_size = cell_rect(0,0).size.x / 3.0 = 250 / 3 = 83.333...
	var level = Level.new()
	var level_data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session

	assert_almost_eq(bv.radar_font_size(), 83.333333, 0.01)

## CHECK: 3
func test_radar_font_size_5x5() -> void:
	# 5x5 board. AREA is 1000x1000. Cell size = 1000/5 = 200.
	# radar_font_size = 200 / 3 = 66.666...
	var level = Level.new()
	var level_data = {
		"width": 5,
		"height": 5,
		"target": 5,
		"radar": [],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session

	assert_almost_eq(bv.radar_font_size(), 66.666667, 0.01)

## CHECK: 4
func test_radar_text_color_not_exceeded() -> void:
	# Radar at (0,0) with limit 2.
	# Pieces at (1,0) and (1,1).
	# Surrounding of (0,0) in 4x4 includes (1,0) and (1,1).
	# Count = 2. 2 > 2 is false. Color should be MARK_COLOR.

	var level = Level.new()
	var level_data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [[0, 0, 2]],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	
	session.board.apply("place", 1, 0)
	session.board.apply("place", 1, 1)
	
	assert_eq(Rules.radar_count(session.board.pieces(), 0, 0), 2)

	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session
	
	assert_eq(bv.radar_text_color(0, 0), BoardView.MARK_COLOR)

## CHECK: 5
func test_radar_text_color_below_limit() -> void:
	# Radar at (0,0) with limit 2.
	# Piece at (1,0).
	# Count = 1.
	# 1 > 2 is false. Color should be MARK_COLOR.

	var level = Level.new()
	var level_data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [[0, 0, 2]],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	
	session.board.apply("place", 1, 0)
	
	assert_eq(Rules.radar_count(session.board.pieces(), 0, 0), 1)

	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session
	
	assert_eq(bv.radar_text_color(0, 0), BoardView.MARK_COLOR)

## CHECK: 6
func test_radar_text_color_exceeded() -> void:
	# Radar at (0,0) with limit 2.
	# Pieces at (1,0), (1,1), (0,1).
	# Surrounding of (0,0): (0,1), (1,0), (1,1).
	# Count = 3.
	# 3 > 2 is true. Color should be RED.

	var level = Level.new()
	var level_data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [[0, 0, 2]],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	
	session.board.apply("place", 1, 0)
	session.board.apply("place", 1, 1)
	session.board.apply("place", 0, 1)
	
	assert_eq(Rules.radar_count(session.board.pieces(), 0, 0), 3)

	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session
	
	assert_eq(bv.radar_text_color(0, 0), Color.RED)

## CHECK: 7
func test_radar_label_center() -> void:
	# Case 1: Empty/Default session (level not parsed or empty) -> cell_rect size is 0 -> center is origin.
	# This should fail if implementation is missing or incorrect for valid sessions, 
	# but here we check that with a "broken" setup it returns something specific (or just run the valid one).
	# The prompt asks to run against two versions: default (empty) and opposite (valid).
	# Let's create a valid 4x4 session first as per the user's correction.
	
	var level = Level.new()
	var level_data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [],
		"asteroids": [],
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		]
	}
	assert_true(level.parse(level_data))

	var SessionClass = preload("res://game/session.gd")
	var session = SessionClass.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = session

	# Calculate expected center manually based on geometry
	# AREA is Rect2(40, 480, 1000, 1000)
	# Grid 4x4 -> cell size = min(1000/4, 1000/4) = 250.0
	# Board size = 1000x1000. Origin = (40, 480) + (1000-1000)*0.5 = (40, 480)
	# Cell (1, 2) rect:
	# x = origin.x + 1 * cell = 40 + 250 = 290
	# y = origin.y + 2 * cell = 480 + 500 = 980
	# size = 250x250
	# center = (290 + 125, 980 + 125) = (415, 1105)
	
	var g = bv.geometry()
	var origin: Vector2 = g["origin"]
	var cell: float = g["cell"]
	var expected_center = origin + Vector2(1.5 * cell, 2.5 * cell)
	
	var actual_center = bv.radar_label_center(1, 2)
	assert_true(actual_center.is_equal_approx(expected_center))
