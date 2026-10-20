extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionSave = preload("res://game/session_save.gd")


func _start_main(save_path: String = "") -> Node:
	var m = MainScene.instantiate()
	if save_path != "":
		m.save_path = save_path
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr1098_1_go_back_saves_and_emits_title_requested() -> void:
	SessionSave.write_text("user://test_cr_1098.json", "")
	var m = await _start_main("user://test_cr_1098.json")
	m.session.board.apply("mark", 0, 0)
	m.session.moves = 4
	watch_signals(m)
	m.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	assert_signal_emitted(m, "title_requested")
	var d = SessionSave.read_json("user://test_cr_1098.json")
	assert_eq(d["moves"], 4)
	assert_eq(d["rows"][0][0], "x")


## CHECK: 2
func test_cr1098_2_go_back_closes_rules_panel() -> void:
	var m = await _start_main()
	m.hud.settings_pressed.emit()
	assert_true(m.rules_panel.visible)
	watch_signals(m)
	m.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	assert_false(m.rules_panel.visible)
	assert_signal_not_emitted(m, "title_requested")


## CHECK: 3
func test_cr1098_3_on_title_requested_saves_progress() -> void:
	SessionSave.write_text("user://test_cr_1098_b.json", "")
	var m = await _start_main("user://test_cr_1098_b.json")
	m.session.board.apply("mark", 1, 0)
	m.session.moves = 5
	m.on_title_requested()
	var d = SessionSave.read_json("user://test_cr_1098_b.json")
	assert_eq(d["moves"], 5)
	assert_eq(d["rows"][0][1], "x")
