extends GutTest

const Session = preload("res://game/session.gd")
const BoardState = preload("res://core/board_state.gd")


func test_request_hint_initial() -> void:
	## CHECK: 1
	var s = Session.new()
	var ok = s.request_hint()
	assert_true(ok)
	assert_eq(s.hints, 2)
	assert_eq(s.current_hint, {"cell": Vector2i(1, 0), "kind": "next_piece", "text": "AN ALIEN GOES HERE. DOUBLE TAP TO PLACE IT."})


func test_apply_hint_initial() -> void:
	## CHECK: 2
	var s = Session.new()
	s.request_hint()
	var ok = s.apply_hint()
	assert_true(ok)
	assert_eq(s.board.state_at(1, 0), BoardState.PIECE)
	assert_eq(s.current_hint, {})
	assert_eq(s.moves, 1)


func test_request_hint_wrong_mark() -> void:
	## CHECK: 3
	var s = Session.new()
	s.tap(3, 1)
	s.request_hint()
	assert_eq(s.current_hint["kind"], "wrong_mark")
	assert_eq(s.current_hint["cell"], Vector2i(3, 1))
	s.apply_hint()
	assert_eq(s.board.state_at(3, 1), BoardState.EMPTY)


func test_request_hint_wrong_piece() -> void:
	## CHECK: 4
	var s = Session.new()
	s.double_tap(0, 0)
	s.request_hint()
	assert_eq(s.current_hint["kind"], "wrong_piece")
	assert_eq(s.current_hint["cell"], Vector2i(0, 0))
	s.apply_hint()
	assert_eq(s.board.state_at(0, 0), BoardState.EMPTY)


func test_apply_hint_without_request() -> void:
	## CHECK: 5
	var s = Session.new()
	var ok = s.apply_hint()
	assert_false(ok)
	assert_eq(s.moves, 0)
	s.request_hint()
	ok = s.apply_hint()
	assert_true(ok)


func test_request_hint_exhaustion() -> void:
	## CHECK: 6
	var s = Session.new()
	assert_true(s.request_hint())
	assert_true(s.request_hint())
	assert_true(s.request_hint())
	assert_eq(s.hints, 0)
	assert_false(s.request_hint())


func test_current_hint_reset_on_next_level() -> void:
	## CHECK: 7
	var s = Session.new()
	s.request_hint()
	assert_ne(s.current_hint, {})
	s.next_level()
	assert_eq(s.current_hint, {})


func test_apply_hint_clears_level() -> void:
	## CHECK: 8
	var s = Session.new()
	s.double_tap(1, 0)
	s.double_tap(3, 1)
	s.double_tap(0, 2)
	s.request_hint()
	assert_eq(s.current_hint["cell"], Vector2i(2, 3))
	assert_eq(s.current_hint["kind"], "next_piece")
	s.apply_hint()
	assert_eq(s.status, "cleared")
	assert_eq(s.score, 100)
