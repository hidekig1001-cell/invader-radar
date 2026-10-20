extends GutTest

const Session = preload("res://game/session.gd")
const SessionSave = preload("res://game/session_save.gd")


## CHECK: 1
func test_save_dict_includes_moves_elapsed_level_rows() -> void:
	var s = Session.new()
	s.tap(0, 0)
	s.tick(4.5)
	var d = s.save_dict()
	assert_eq(d["moves"], 1)
	assert_eq(d["elapsed"], 4.5)
	assert_eq(d["level"], s.level.to_dict())
	assert_eq(d["rows"], s.board.snapshot()["rows"])
	assert_eq(d["rows"][0][0], "x")


## CHECK: 2
func test_session_save_roundtrip_preserves_new_fields() -> void:
	var s = Session.new()
	s.tap(0, 0)
	s.tick(4.5)
	var save_data = s.save_dict()
	SessionSave.write_json("user://test_cr_1080b.json", save_data)
	var d = SessionSave.read_json("user://test_cr_1080b.json")
	assert_eq(d["moves"], 1)
	assert_eq(typeof(d["moves"]), TYPE_INT)
	assert_eq(d["elapsed"], 4.5)
	assert_eq(d["rows"], s.board.snapshot()["rows"])
	assert_eq(d["level"]["width"], s.level.width)
	assert_eq(d["level"]["regions"].size(), s.level.height)


## CHECK: 3
func test_session_save_read_json_filters_invalid_types() -> void:
	# Case 1: Invalid types in level and rows
	SessionSave.write_json("user://test_cr_1080b.json", {
		"level_index": 2,
		"score": 100,
		"hints": 3,
		"moves": 3,
		"elapsed": 2.0,
		"level": 5,
		"rows": ["P..", 7, "x.."]
	})
	var d = SessionSave.read_json("user://test_cr_1080b.json")
	assert_eq(d["rows"], ["P..", "x.."])
	assert_false(d.has("level"))
	assert_eq(d["moves"], 3)

	# Case 2: Missing optional fields
	SessionSave.write_json("user://test_cr_1080b.json", {
		"level_index": 2,
		"score": 100,
		"hints": 3
	})
	var d2 = SessionSave.read_json("user://test_cr_1080b.json")
	assert_false(d2.has("rows"))
	assert_false(d2.has("moves"))
