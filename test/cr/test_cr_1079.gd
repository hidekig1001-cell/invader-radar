extends GutTest

const Session = preload("res://game/session.gd")
const SessionSave = preload("res://game/session_save.gd")


## CHECK: 1
func test_clear_records_and_max_cleared() -> void:
	var s = Session.new()
	assert_eq(s.max_cleared, 0)
	assert_eq(s.clear_records.size(), 0)

	s.tick(12.5)
	s.solve_now()
	assert_eq(s.clear_records.size(), 1)
	assert_eq(s.clear_records[0]["level"], 1)
	assert_eq(s.clear_records[0]["seconds"], 12.5)
	assert_eq(s.clear_records[0]["moves"], s.moves)
	assert_eq(s.max_cleared, 1)

	s.next_level()
	s.tick(3.0)
	s.solve_now()
	assert_eq(s.clear_records.size(), 2)
	assert_eq(s.clear_records[1]["level"], 2)
	assert_eq(s.clear_records[1]["seconds"], 3.0)
	assert_eq(s.max_cleared, 2)


## CHECK: 2
func test_save_and_restore_clear_records() -> void:
	var s = Session.new()
	s.tick(12.5)
	s.solve_now()
	var d = s.save_dict()
	assert_eq(d["max_cleared"], 1)
	assert_eq(d["clears"].size(), 1)
	assert_eq(d["clears"][0]["seconds"], 12.5)

	var t = Session.new()
	t.restore_dict({
		"level_index": 1,
		"score": 0,
		"hints": 3,
		"max_cleared": 5,
		"clears": [{"level": 5, "seconds": 20.0, "moves": 7}]
	})
	assert_eq(t.max_cleared, 5)
	assert_eq(t.clear_records.size(), 1)
	assert_eq(t.clear_records[0]["seconds"], 20.0)

	var u = Session.new()
	u.restore_dict({"level_index": 1, "score": 0, "hints": 3})
	assert_eq(u.max_cleared, 0)
	assert_eq(u.clear_records.size(), 0)


## CHECK: 3
func test_session_save_json_roundtrip_with_clears() -> void:
	var path = "user://test_cr_1079.json"
	SessionSave.write_json(path, {
		"level_index": 2,
		"score": 100,
		"hints": 3,
		"max_cleared": 2,
		"clears": [{"level": 1, "seconds": 12.5, "moves": 4}]
	})
	var d = SessionSave.read_json(path)
	assert_eq(d["max_cleared"], 2)
	assert_eq(d["clears"].size(), 1)
	assert_eq(d["clears"][0]["level"], 1)
	assert_eq(d["clears"][0]["seconds"], 12.5)
	assert_eq(d["clears"][0]["moves"], 4)

	SessionSave.write_json(path, {"level_index": 2, "score": 100, "hints": 3})
	var d2 = SessionSave.read_json(path)
	assert_eq(d2, {"level_index": 2, "score": 100, "hints": 3})
