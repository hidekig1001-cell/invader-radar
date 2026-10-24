extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")


func _make_session(regions: Array) -> SessionScript:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [],
		"asteroids": [],
		"regions": regions
	})
	return SessionScript.new([level])


## CHECK: 1
func test_piece_color_name() -> void:
	var s = _make_session([[0, 1, 2, 3], [4, 5, 6, 7], [0, 1, 2, 3], [4, 5, 6, 7]])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s

	assert_eq(bv.piece_color_name(0, 0), "navy")
	assert_eq(bv.piece_color_name(1, 0), "orange")
	assert_eq(bv.piece_color_name(2, 0), "pink")
	assert_eq(bv.piece_color_name(3, 0), "green")
	assert_eq(bv.piece_color_name(0, 1), "cyan")
	assert_eq(bv.piece_color_name(1, 1), "purple")
	assert_eq(bv.piece_color_name(2, 1), "pink")
	assert_eq(bv.piece_color_name(3, 1), "navy")

	var s2 = _make_session([[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]])
	s2.board.apply("place", 0, 0)
	s2.board.apply("place", 1, 1)
	bv.session = s2

	assert_eq(bv.piece_color_name(0, 0), "conflict")


## CHECK: 2
func test_piece_texture_and_rect() -> void:
	var s = _make_session([[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s

	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_navy.png")
	assert_eq(bv.piece_texture(1, 0).resource_path, "res://assets/piece_orange.png")
	assert_eq(bv.rock_texture().resource_path, "res://assets/rock.png")

	s.board.apply("place", 0, 0)
	s.board.apply("place", 1, 1)
	assert_eq(bv.piece_texture(0, 0).resource_path, "res://assets/piece_conflict.png")

	var r = bv.piece_image_rect(Rect2(0, 0, 100, 100))
	assert_true(r.is_equal_approx(Rect2(6, 6, 88, 88)))
