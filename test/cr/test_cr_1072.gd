extends GutTest

const Session = preload("res://game/session.gd")
const BoardState = preload("res://core/board_state.gd")
const Solver = preload("res://core/solver.gd")


## CHECK: 1
func test_given_piece_setup() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 20, "score": 0, "hints": 3})
	
	assert_true(s.level.width >= 6)
	assert_eq(s.given, Solver.solutions(s.level, 1)[0][s.level.height / 2])
	assert_eq(s.board.state_at(s.given.x, s.given.y), BoardState.PIECE)
	assert_eq(s.board.pieces().size(), 1)
	assert_eq(s.moves, 0)
	assert_eq(s.board.history_size(), 0)

	var s5 = Session.new()
	s5.rng.seed = 1
	s5.restore_dict({"level_index": 5, "score": 0, "hints": 3})
	assert_eq(s5.given, Vector2i(-1, -1))
	assert_eq(s5.board.pieces().size(), 0)


## CHECK: 2
func test_given_piece_immutable() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 20, "score": 0, "hints": 3})
	
	assert_false(s.double_tap(s.given.x, s.given.y))
	assert_false(s.tap(s.given.x, s.given.y))
	assert_false(s.undo())
	assert_eq(s.board.state_at(s.given.x, s.given.y), BoardState.PIECE)
	
	s.restart_level()
	assert_eq(s.board.pieces().size(), 1)
	assert_eq(s.board.state_at(s.given.x, s.given.y), BoardState.PIECE)
