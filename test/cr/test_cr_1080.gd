extends GutTest

const BoardState = preload("res://core/board_state.gd")


## CHECK: 1
func test_restore_rows_from_snapshot() -> void:
	var a = BoardState.new(3, 2)
	a.apply("place", 0, 0)
	a.apply("mark", 2, 1)
	var s = a.snapshot()

	var b = BoardState.new(3, 2)
	assert_eq(b.restore_rows(s["rows"]), OK)
	assert_eq(b.snapshot(), s)
	assert_eq(b.history_size(), 0)


## CHECK: 2
func test_restore_rows_clears_history_and_state() -> void:
	var b = BoardState.new(3, 2)
	b.apply("mark", 1, 1)
	assert_eq(b.restore_rows(["P.x", "..."]), OK)
	assert_eq(b.state_at(0, 0), BoardState.PIECE)
	assert_eq(b.state_at(2, 0), BoardState.MARK)
	assert_eq(b.state_at(1, 1), BoardState.EMPTY)
	assert_false(b.undo())


## CHECK: 3
func test_restore_rows_invalid_params() -> void:
	var b = BoardState.new(3, 2)
	b.apply("place", 1, 0)
	var s = b.snapshot()

	# Wrong row count (1 vs height 2)
	assert_eq(b.restore_rows(["P.."]), ERR_INVALID_PARAMETER)
	assert_eq(b.snapshot(), s)

	# Invalid character '?' in row
	assert_eq(b.restore_rows(["P.?", "..."]), ERR_INVALID_PARAMETER)
	assert_eq(b.snapshot(), s)

	# Wrong width (4 vs width 3)
	assert_eq(b.restore_rows(["P...", "..."]), ERR_INVALID_PARAMETER)
	assert_eq(b.snapshot(), s)

	assert_eq(b.history_size(), 1)
