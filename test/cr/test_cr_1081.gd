extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionSave = preload("res://game/session_save.gd")


## CHECK: 1
func test_cr1081_1_application_paused_saves_progress() -> void:
	SessionSave.write_text("user://test_cr_1081.json", "")
	var m = MainScene.instantiate()
	m.save_path = "user://test_cr_1081.json"
	add_child_autofree(m)
	await wait_frames(2)
	
	m.session.board.apply("mark", 0, 0)
	m.session.moves = 2
	
	m.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	
	var d = SessionSave.read_json("user://test_cr_1081.json")
	assert_eq(d["moves"], 2)
	assert_eq(d["rows"][0][0], "x")


## CHECK: 2
func test_cr1081_2_wm_close_request_saves_progress() -> void:
	SessionSave.write_text("user://test_cr_1081_b.json", "")
	var m = MainScene.instantiate()
	m.save_path = "user://test_cr_1081_b.json"
	add_child_autofree(m)
	await wait_frames(2)
	
	m.session.board.apply("mark", 1, 0)
	m.session.moves = 3
	
	m.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	
	var d = SessionSave.read_json("user://test_cr_1081_b.json")
	assert_eq(d["moves"], 3)
	assert_eq(d["rows"][0][1], "x")
