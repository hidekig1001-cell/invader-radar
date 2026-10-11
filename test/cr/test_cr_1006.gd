extends GutTest

const Hint = preload("res://core/hint.gd")
const BoardState = preload("res://core/board_state.gd")
const Level = preload("res://game/level.gd")


func _make_level() -> Level:
	var lv = Level.new()
	lv.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[3, 3, 0, 0], [3, 3, 1, 2], [1, 1, 1, 2], [1, 1, 1, 2]]})
	return lv


func test_1_empty_board_next_piece() -> void:
	## CHECK: 1
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	var result = Hint.next_hint(b, lv)
	assert_eq(result, {"cell": Vector2i(2, 0), "kind": "next_piece", "text": "A PIECE GOES HERE. DOUBLE TAP TO PLACE IT."})


func test_2_wrong_mark_priority() -> void:
	## CHECK: 2
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	b.apply("mark", 0, 1)
	b.apply("mark", 3, 2)
	var result = Hint.next_hint(b, lv)
	assert_eq(result["cell"], Vector2i(0, 1))
	assert_eq(result["kind"], "wrong_mark")
	assert_eq(result["text"], "THIS CELL IS MARKED BY MISTAKE. TAP TO REMOVE THE X.")


func test_3_wrong_mark_before_wrong_piece() -> void:
	## CHECK: 3
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 3)
	var result = Hint.next_hint(b, lv)
	assert_eq(result["kind"], "wrong_mark")
	assert_eq(result["cell"], Vector2i(1, 3))


func test_4_wrong_piece() -> void:
	## CHECK: 4
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("place", 0, 0)
	var result = Hint.next_hint(b, lv)
	assert_eq(result["cell"], Vector2i(0, 0))
	assert_eq(result["kind"], "wrong_piece")
	assert_eq(result["text"], "THIS PIECE IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT.")


func test_5_next_piece_after_some_placed() -> void:
	## CHECK: 5
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	b.apply("place", 2, 0)
	b.apply("place", 0, 1)
	b.apply("mark", 0, 0)
	var result = Hint.next_hint(b, lv)
	assert_eq(result["cell"], Vector2i(3, 2))
	assert_eq(result["kind"], "next_piece")


func test_6_correct_board_and_clear() -> void:
	## CHECK: 6
	var lv = _make_level()
	var b = BoardState.new(4, 4)
	b.apply("place", 2, 0)
	b.apply("place", 0, 1)
	b.apply("place", 3, 2)
	b.apply("place", 1, 3)
	var result = Hint.next_hint(b, lv)
	assert_eq(result, {})
	
	b.apply("clear", 1, 3)
	var result2 = Hint.next_hint(b, lv)
	assert_eq(result2["cell"], Vector2i(1, 3))
	assert_eq(result2["kind"], "next_piece")
