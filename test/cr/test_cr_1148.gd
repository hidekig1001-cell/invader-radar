extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")


func _make_session_and_boardview() -> Dictionary:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [],
		"asteroids": [],
		"regions": [[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]]
	})
	var s = SessionScript.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s
	return {"s": s, "bv": bv}


## CHECK: 1
func test_cr_1148_piece_texture_pose_selection() -> void:
	var ctx = _make_session_and_boardview()
	var s = ctx["s"]
	var bv = ctx["bv"]

	# Place a piece at (0,0). Region 0 maps to "navy".
	s.board.apply("place", 0, 0)

	# Check PIECE_POSE_TEXTURES constant structure
	assert_true(bv.PIECE_POSE_TEXTURES != null)
	assert_true(bv.PIECE_POSE_TEXTURES.has("purple"))
	assert_eq(bv.PIECE_POSE_TEXTURES["purple"].size(), 4)
	assert_eq(bv.PIECE_POSE_TEXTURES["purple"][3].resource_path, "res://assets/piece_purple_4.png")

	# Check piece_texture with specific poses for (0,0) which is "navy"
	bv.piece_poses[Vector2i(0, 0)] = 0
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_navy.png")

	bv.piece_poses[Vector2i(0, 0)] = 1
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_navy_2.png")

	bv.piece_poses[Vector2i(0, 0)] = 2
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_navy_3.png")

	bv.piece_poses[Vector2i(0, 0)] = 3
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_navy_4.png")

	# Place another piece at (1,1) to create a conflict at (0,0)? 
	# The CR says: "s.board.apply("place", 1, 1) をしたあとの bv.piece_texture(0, 0).resource_path は "res://assets/piece_conflict.png""
	# This implies placing at (1,1) causes a conflict at (0,0). 
	s.board.apply("place", 1, 1)
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_conflict.png")


## CHECK: 2
func test_cr_1148_piece_pose_logic_and_cleanup() -> void:
	var ctx = _make_session_and_boardview()
	var s = ctx["s"]
	var bv = ctx["bv"]

	# Place a piece at (2,0). Region 2 maps to "pink" (index 2 in REGION_PIECE_COLORS: navy, orange, pink...).
	s.board.apply("place", 2, 0)

	# Check piece_pose for empty cell (3,3) returns 0
	assert_eq(bv.piece_pose(3, 3), 0)

	# Check piece_pose for occupied cell (2,0)
	var p = bv.piece_pose(2, 0)
	assert_true(p >= 0 and p <= 3)
	assert_true(bv.piece_poses.has(Vector2i(2, 0)))

	# Check consistency: calling again returns same value
	var p2 = bv.piece_pose(2, 0)
	assert_eq(p, p2)

	# Check forget_empty_poses keeps occupied cells
	bv.forget_empty_poses()
	assert_true(bv.piece_poses.has(Vector2i(2, 0)))

	# Clear the piece and check forget_empty_poses removes it
	s.board.apply("clear", 2, 0)
	bv.forget_empty_poses()
	assert_false(bv.piece_poses.has(Vector2i(2, 0)))
