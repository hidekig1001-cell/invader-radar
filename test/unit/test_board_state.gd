# core/board_state.gd の単体テスト。
extends GutTest

const BoardState = preload("res://core/board_state.gd")


func test_starts_empty() -> void:
	var b = BoardState.new(4, 4)
	assert_eq(b.state_at(0, 0), BoardState.EMPTY)
	assert_eq(b.pieces().size(), 0)
	assert_eq(b.marks().size(), 0)


func test_mark_place_clear() -> void:
	var b = BoardState.new(4, 4)
	assert_eq(b.apply("mark", 1, 2), OK)
	assert_eq(b.state_at(1, 2), BoardState.MARK)
	assert_eq(b.apply("place", 1, 2), OK)
	assert_eq(b.state_at(1, 2), BoardState.PIECE)
	assert_eq(b.apply("clear", 1, 2), OK)
	assert_eq(b.state_at(1, 2), BoardState.EMPTY)


func test_x_and_y_are_not_swapped() -> void:
	var b = BoardState.new(4, 4)
	b.apply("place", 3, 0)
	assert_eq(b.state_at(3, 0), BoardState.PIECE)
	assert_eq(b.state_at(0, 3), BoardState.EMPTY)
	assert_eq(b.pieces(), [Vector2i(3, 0)])


func test_invalid_parameters() -> void:
	var b = BoardState.new(4, 4)
	assert_eq(b.apply("mark", 4, 0), ERR_INVALID_PARAMETER)
	assert_eq(b.apply("place", -1, 0), ERR_INVALID_PARAMETER)
	assert_eq(b.apply("mark", 0, 9), ERR_INVALID_PARAMETER)
	assert_eq(b.apply("jump", 0, 0), ERR_INVALID_PARAMETER)
	assert_eq(b.history_size(), 0)


func test_pieces_and_marks_lists() -> void:
	var b = BoardState.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("place", 2, 3)
	b.apply("mark", 1, 1)
	assert_eq(b.pieces().size(), 2)
	assert_has(b.pieces(), Vector2i(2, 3))
	assert_eq(b.marks(), [Vector2i(1, 1)])


func test_undo_restores_previous_state() -> void:
	var b = BoardState.new(4, 4)
	b.apply("mark", 1, 1)
	b.apply("place", 1, 1)
	assert_true(b.undo())
	assert_eq(b.state_at(1, 1), BoardState.MARK)
	assert_true(b.undo())
	assert_eq(b.state_at(1, 1), BoardState.EMPTY)
	assert_false(b.undo(), "戻すものがなければ false")


func test_same_state_is_not_recorded() -> void:
	var b = BoardState.new(4, 4)
	assert_eq(b.apply("clear", 0, 0), OK)
	assert_eq(b.history_size(), 0)
	b.apply("mark", 0, 0)
	b.apply("mark", 0, 0)
	assert_eq(b.history_size(), 1)


func test_snapshot() -> void:
	var b = BoardState.new(3, 2)
	b.apply("mark", 0, 0)
	b.apply("place", 2, 1)
	var s: Dictionary = b.snapshot()
	assert_eq(s["width"], 3)
	assert_eq(s["height"], 2)
	assert_eq(s["rows"], ["x..", "..P"])
	assert_eq(s["marks"], 1)
	assert_eq(s["pieces"], 1)
