# core/rules.gd（土台の版: 駒が target 個あれば解けた）の単体テスト。
extends GutTest

const BoardState = preload("res://core/board_state.gd")
const Rules = preload("res://core/rules.gd")
const Level = preload("res://game/level.gd")


func _level(target: int):
	var lv = Level.new()
	var ok: bool = lv.parse({"id": 1, "width": 4, "height": 4, "target": target,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	assert_true(ok)
	return lv


func test_not_solved_when_fewer_pieces() -> void:
	var b = BoardState.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("place", 2, 1)
	assert_false(Rules.is_solved(b, _level(4)))


func test_solved_when_target_pieces() -> void:
	var b = BoardState.new(4, 4)
	for i in range(4):
		b.apply("place", i, i)
	assert_true(Rules.is_solved(b, _level(4)))


func test_marks_do_not_count() -> void:
	var b = BoardState.new(4, 4)
	for i in range(4):
		b.apply("mark", i, i)
	assert_false(Rules.is_solved(b, _level(4)))


func test_target_is_read_from_the_level() -> void:
	var b = BoardState.new(4, 4)
	b.apply("place", 0, 0)
	assert_true(Rules.is_solved(b, _level(1)))
	assert_false(Rules.is_solved(b, _level(2)))


func test_null_is_not_solved() -> void:
	assert_false(Rules.is_solved(null, _level(4)))
	assert_false(Rules.is_solved(BoardState.new(4, 4), null))
