extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionSave = preload("res://game/session_save.gd")
const AppScript = preload("res://scenes/app.gd")


func _start_main(save_path: String) -> Node:
	var m = MainScene.instantiate()
	m.save_path = save_path
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr1051_1_load_valid_save() -> void:
	var p = "user://test_cr1051_a.json"
	SessionSave.write_json(p, {"level_index": 2, "score": 150, "hints": 1})
	var m = await _start_main(p)
	assert_eq(m.session.level_index, 2)
	assert_eq(m.session.score, 150)
	assert_eq(m.session.hints, 1)


## CHECK: 2
func test_cr1051_2_load_invalid_save_and_overwrite() -> void:
	var p = "user://test_cr1051_b.json"
	SessionSave.write_text(p, "{not json")
	var m = await _start_main(p)
	assert_eq(m.session.level_index, 0)
	assert_eq(m.session.score, 0)
	assert_eq(m.session.hints, 3)
	m.session.score = 30
	m.save_progress()
	var data = SessionSave.read_json(p)
	assert_eq(data["level_index"], 0)
	assert_eq(data["score"], 30)
	assert_eq(data["hints"], 3)


## CHECK: 3
func test_cr1051_3_save_on_next_level() -> void:
	var p = "user://test_cr1051_c.json"
	SessionSave.write_text(p, "")
	var m = await _start_main(p)
	m.session.status = "cleared"
	m._on_touch_down(Vector2(540, 900))
	assert_eq(m.session.level_index, 1)
	var data = SessionSave.read_json(p)
	assert_eq(data["level_index"], 1)
	assert_eq(data["score"], m.session.score)
	assert_eq(data["hints"], m.session.hints)


## CHECK: 4
func test_cr1051_4_empty_save_path_no_load_then_save() -> void:
	var p = "user://test_cr1051_f.json"
	SessionSave.write_json(p, {"level_index": 2, "score": 150, "hints": 1})
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.save_path, "")
	assert_eq(m.session.level_index, 0)
	assert_eq(m.session.score, 0)
	assert_eq(m.session.hints, 3)
	m.save_path = p
	m.session.score = 60
	m.save_progress()
	var data = SessionSave.read_json(p)
	assert_eq(data["level_index"], 0)
	assert_eq(data["score"], 60)
	assert_eq(data["hints"], 3)


## CHECK: 5
func test_cr1051_5_save_progress_writes_score() -> void:
	var p = "user://test_cr1051_d.json"
	var m = await _start_main(p)
	m.session.score = 40
	m.save_progress()
	var data = SessionSave.read_json(p)
	assert_eq(data["score"], 40)


## CHECK: 6
func test_cr1051_6_app_save_path_propagation() -> void:
	var app = AppScript.new()
	add_child_autofree(app)
	await wait_frames(2)
	assert_eq(app.save_path, "user://progress.json")
	app.save_path = "user://test_cr1051_e.json"
	app.start_game(false)
	await wait_frames(2)
	assert_eq(app.main.save_path, "user://test_cr1051_e.json")
