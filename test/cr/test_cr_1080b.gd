extends GutTest

const Session = preload("res://game/session.gd")
const SessionSave = preload("res://game/session_save.gd")


## CHECK: 1
func test_restore_dict_restores_level_board_moves_elapsed() -> void:
	var s = Session.new()
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	s.board.apply("mark", 0, 0)
	s.moves = 1
	s.tick(3.0)
	SessionSave.write_json("user://test_cr_1080c.json", s.save_dict())

	var t = Session.new()
	t.restore_dict(SessionSave.read_json("user://test_cr_1080c.json"))

	assert_eq(t.level_index, 13)
	assert_eq(t.level.to_dict(), s.level.to_dict())
	assert_eq(t.board.snapshot()["rows"], s.board.snapshot()["rows"])
	assert_eq(t.board.snapshot()["rows"][0][0], "x")
	assert_eq(t.moves, 1)
	assert_almost_eq(t.elapsed, 3.0, 0.001)
	assert_eq(t.board.history_size(), 0)

	var d = SessionSave.read_json("user://test_cr_1080c.json")
	d["level_index"] = 2
	var u = Session.new()
	u.restore_dict(d)

	assert_eq(u.level_index, 2)
	assert_ne(u.level.to_dict(), s.level.to_dict())
	assert_eq(u.moves, 0)
	assert_almost_eq(u.elapsed, 0.0, 0.001)


## CHECK: 2
func test_restore_dict_invalid_rows_resets_moves_elapsed() -> void:
	var s = Session.new()
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	s.board.apply("mark", 0, 0)
	s.moves = 1
	s.tick(3.0)
	SessionSave.write_json("user://test_cr_1080c.json", s.save_dict())

	var d = SessionSave.read_json("user://test_cr_1080c.json")
	d["rows"] = ["P"]
	var t = Session.new()
	t.restore_dict(d)

	assert_eq(t.level.to_dict(), s.level.to_dict())
	assert_eq(t.moves, 0)
	assert_almost_eq(t.elapsed, 0.0, 0.001)
	assert_eq(t.board.marks().size(), 0)
