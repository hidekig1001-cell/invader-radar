extends GutTest

const Session = preload("res://game/session.gd")
const SessionSave = preload("res://game/session_save.gd")
const BoardState = preload("res://core/board_state.gd")


## CHECK: 1
func test_save_dict_returns_correct_values() -> void:
	var s = Session.new()
	s.level_index = 2
	s.score = 50
	s.hints = 1
	var d = s.save_dict()
	assert_eq(d["level_index"], 2)
	assert_eq(d["score"], 50)
	assert_eq(d["hints"], 1)


## CHECK: 2
func test_restore_dict_clamps_level_index_and_restores_score_hints() -> void:
	var s = Session.new()
	s.restore_dict({"level_index": 1, "score": 7, "hints": 2})
	assert_eq(s.level_index, 1)
	s.restore_dict({"level_index": 99, "score": 7, "hints": 2})
	assert_eq(s.level_index, 0)
	assert_eq(s.score, 7)
	assert_eq(s.hints, 2)
	s.restore_dict({"level_index": -1, "score": 8, "hints": 1})
	assert_eq(s.level_index, 0)
	assert_eq(s.score, 8)
	assert_eq(s.hints, 1)


## CHECK: 3
func test_restore_dict_resets_board_and_moves() -> void:
	var s = Session.new()
	s.tap(0, 0)
	assert_eq(s.moves, 1)
	assert_eq(s.board.state_at(0, 0), BoardState.MARK)
	s.restore_dict({"level_index": 1, "score": 10, "hints": 2})
	assert_eq(s.moves, 0)
	assert_eq(s.level_index, 1)
	assert_eq(s.score, 10)
	assert_eq(s.hints, 2)
	assert_eq(s.board.state_at(0, 0), BoardState.EMPTY)


## CHECK: 4
func test_write_text_writes_string_to_file() -> void:
	var path = "user://cr1050_text.json"
	SessionSave.write_text(path, "abc")
	var content = FileAccess.get_file_as_string(path)
	assert_eq(content, "abc")


## CHECK: 5
func test_write_json_and_read_json_roundtrip_and_int_conversion() -> void:
	var path = "user://cr1050_a.json"
	SessionSave.write_json(path, {"level_index": 2, "score": 50, "hints": 1})
	var d = SessionSave.read_json(path)
	assert_eq(d["level_index"], 2)
	assert_eq(d["score"], 50)
	assert_eq(d["hints"], 1)
	assert_true(typeof(d["level_index"]) == TYPE_INT)
	assert_true(typeof(d["score"]) == TYPE_INT)
	assert_true(typeof(d["hints"]) == TYPE_INT)
	SessionSave.write_text(path, '{"level_index": 2.9, "score": 50.9, "hints": 1.9}')
	var d2 = SessionSave.read_json(path)
	assert_eq(d2["level_index"], 2)
	assert_eq(d2["score"], 50)
	assert_eq(d2["hints"], 1)
	assert_true(typeof(d2["level_index"]) == TYPE_INT)
	assert_true(typeof(d2["score"]) == TYPE_INT)
	assert_true(typeof(d2["hints"]) == TYPE_INT)


## CHECK: 6
func test_read_json_returns_empty_for_nonexistent_file_then_roundtrip() -> void:
	var path = "user://cr1050_b.json"
	SessionSave.write_text(path, "")
	var d_empty = SessionSave.read_json(path)
	assert_eq(d_empty, {})
	SessionSave.write_json(path, {"level_index": 1, "score": 0, "hints": 3})
	var d = SessionSave.read_json(path)
	assert_eq(d["level_index"], 1)
	assert_eq(d["score"], 0)
	assert_eq(d["hints"], 3)


## CHECK: 7
func test_read_json_returns_empty_for_invalid_json() -> void:
	var path = "user://cr1050_c.json"
	SessionSave.write_json(path, {"level_index": 1, "score": 0, "hints": 3})
	var d = SessionSave.read_json(path)
	assert_eq(d["level_index"], 1)
	assert_eq(d["score"], 0)
	assert_eq(d["hints"], 3)
	SessionSave.write_text(path, "{not json")
	var d_bad = SessionSave.read_json(path)
	assert_eq(d_bad, {})


## CHECK: 8
func test_read_json_returns_empty_for_non_dict_json() -> void:
	var path = "user://cr1050_d.json"
	SessionSave.write_json(path, {"level_index": 1, "score": 0, "hints": 3})
	var d = SessionSave.read_json(path)
	assert_eq(d["level_index"], 1)
	assert_eq(d["score"], 0)
	assert_eq(d["hints"], 3)
	SessionSave.write_text(path, "[1, 2]")
	var d_bad = SessionSave.read_json(path)
	assert_eq(d_bad, {})


## CHECK: 9
func test_read_json_returns_empty_for_missing_keys() -> void:
	var path = "user://cr1050_e.json"
	SessionSave.write_json(path, {"level_index": 1, "score": 0, "hints": 3})
	var d = SessionSave.read_json(path)
	assert_eq(d["level_index"], 1)
	assert_eq(d["score"], 0)
	assert_eq(d["hints"], 3)
	SessionSave.write_json(path, {"level_index": 1, "score": 0})
	var d_bad = SessionSave.read_json(path)
	assert_eq(d_bad, {})
