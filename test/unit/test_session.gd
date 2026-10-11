# game/session.gd の単体テスト（操作の読み替え・手数・スコア・ヒント・面の切り替え）。
extends GutTest

const Session = preload("res://game/session.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")

# テストの中の 3 面（data/levels の面が変わっても、このテストは変わらない）
const LEVEL_DICTS := [
	{"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[3, 3, 0, 0], [3, 3, 1, 2], [1, 1, 1, 2], [1, 1, 1, 2]]},
	{"id": 2, "width": 4, "height": 4, "target": 4, "regions": [[2, 2, 1, 1], [2, 2, 2, 1], [2, 3, 3, 3], [0, 0, 3, 3]]},
	{"id": 3, "width": 4, "height": 4, "target": 4, "regions": [[2, 2, 2, 2], [0, 0, 2, 1], [3, 3, 2, 1], [3, 3, 3, 1]]},
]
# 3 面に共通の答え（x, y）。区域・行・列に 1 つずつ、斜めも含めて隣り合わない
const ANSWER := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 2), Vector2i(1, 3)]


func _session():
	var list: Array = []
	for d in LEVEL_DICTS:
		var lv = Level.new()
		lv.parse(d)
		list.append(lv)
	return Session.new(list)


func _solve(s) -> void:
	for c in ANSWER:
		s.double_tap(c.x, c.y)


func test_initial_state() -> void:
	var s = _session()
	var snap: Dictionary = s.snapshot()
	assert_eq(snap["level"], 1)
	assert_eq(snap["moves"], 0)
	assert_eq(snap["score"], 0)
	assert_eq(snap["hints"], 3)
	assert_eq(snap["status"], "playing")
	assert_eq(snap["board"]["rows"], ["....", "....", "....", "...."])


func test_tap_marks_then_clears() -> void:
	var s = _session()
	assert_true(s.tap(1, 1))
	assert_eq(s.board.state_at(1, 1), BoardState.MARK)
	assert_true(s.tap(1, 1))
	assert_eq(s.board.state_at(1, 1), BoardState.EMPTY)
	assert_eq(s.moves, 2)


func test_double_tap_places_and_removes_piece() -> void:
	var s = _session()
	assert_true(s.double_tap(2, 0))
	assert_eq(s.board.state_at(2, 0), BoardState.PIECE)
	assert_true(s.double_tap(2, 0))
	assert_eq(s.board.state_at(2, 0), BoardState.EMPTY)


func test_double_tap_replaces_mark_with_piece() -> void:
	var s = _session()
	s.tap(0, 3)
	assert_true(s.double_tap(0, 3))
	assert_eq(s.board.state_at(0, 3), BoardState.PIECE)


func test_tap_on_piece_does_nothing() -> void:
	var s = _session()
	s.double_tap(0, 0)
	var moves: int = s.moves
	assert_false(s.tap(0, 0))
	assert_eq(s.board.state_at(0, 0), BoardState.PIECE)
	assert_eq(s.moves, moves)


func test_out_of_board_is_ignored() -> void:
	var s = _session()
	assert_false(s.tap(4, 0))
	assert_false(s.double_tap(-1, 2))
	assert_eq(s.moves, 0)


func test_swipe_marks_only_empty_cells_as_one_move() -> void:
	var s = _session()
	s.double_tap(1, 0)
	s.tap(2, 0)
	var moves: int = s.moves
	assert_true(s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]))
	assert_eq(s.board.snapshot()["rows"][0], "xPxx", "駒と × はそのまま")
	assert_eq(s.moves, moves + 1)
	assert_false(s.swipe([Vector2i(0, 0)]), "変わらない swipe は手数に数えない")
	assert_eq(s.moves, moves + 1)


func test_undo_restores_board() -> void:
	var s = _session()
	s.tap(1, 1)
	assert_true(s.undo())
	assert_eq(s.board.state_at(1, 1), BoardState.EMPTY)
	assert_false(s.undo())


func test_hints_decrease_to_zero() -> void:
	var s = _session()
	assert_true(s.use_hint())
	assert_eq(s.hints, 2)
	assert_true(s.use_hint())
	assert_true(s.use_hint())
	assert_false(s.use_hint())
	assert_eq(s.hints, 0)


func test_clear_when_target_pieces_placed() -> void:
	var s = _session()
	for i in range(3):
		s.double_tap(ANSWER[i].x, ANSWER[i].y)
	assert_eq(s.status, "playing")
	s.double_tap(ANSWER[3].x, ANSWER[3].y)
	assert_eq(s.status, "cleared")
	assert_eq(s.score, Session.CLEAR_SCORE)
	assert_eq(s.snapshot()["status"], "cleared")


func test_no_input_after_clear() -> void:
	var s = _session()
	_solve(s)
	var moves: int = s.moves
	assert_false(s.tap(0, 0))
	assert_false(s.double_tap(1, 0))
	assert_false(s.swipe([Vector2i(0, 1)]))
	assert_false(s.use_hint())
	assert_eq(s.moves, moves)


func test_next_level_resets_board_and_keeps_score_and_hints() -> void:
	var s = _session()
	s.use_hint()
	_solve(s)
	assert_true(s.next_level())
	assert_eq(s.snapshot()["level"], 2)
	assert_eq(s.status, "playing")
	assert_eq(s.moves, 0)
	assert_eq(s.board.pieces().size(), 0)
	assert_eq(s.score, Session.CLEAR_SCORE)
	assert_eq(s.hints, 2)


func test_next_level_wraps_after_last() -> void:
	var s = _session()
	s.next_level()
	s.next_level()
	assert_eq(s.snapshot()["level"], 3)
	s.next_level()
	assert_eq(s.snapshot()["level"], 1)


func test_restart_level() -> void:
	var s = _session()
	s.next_level()
	s.tap(0, 0)
	s.restart_level()
	assert_eq(s.snapshot()["level"], 2)
	assert_eq(s.moves, 0)
	assert_eq(s.board.marks().size(), 0)


func test_changed_signal_is_emitted() -> void:
	var s = _session()
	watch_signals(s)
	s.tap(0, 0)
	assert_signal_emitted(s, "changed")
