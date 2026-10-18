extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_restart_button_text_en() -> void:
	var m = await _start()
	assert_eq(m.hud.restart_button.text, "RESTART")


## CHECK: 2
func test_restart_button_text_ja() -> void:
	var m = await _start()
	m.hud.set_language("ja")
	assert_eq(m.hud.restart_button.text, "やり直す")


## CHECK: 3
func test_restart_button_rect() -> void:
	var m = await _start()
	var r := Rect2(m.hud.restart_button.position, m.hud.restart_button.size)
	assert_true(r.is_equal_approx(Rect2(380, 260, 320, 100)))


## CHECK: 4
func test_restart_button_no_overlap_moves_label() -> void:
	var m = await _start()
	var r := Rect2(m.hud.restart_button.position, m.hud.restart_button.size)
	assert_false(r.intersects(m.hud.moves_label.get_rect()))
	assert_true(r.intersects(Rect2(400, 270, 50, 50)))


## CHECK: 5
func test_restart_button_no_overlap_undo_button() -> void:
	var m = await _start()
	var r := Rect2(m.hud.restart_button.position, m.hud.restart_button.size)
	assert_false(r.intersects(m.hud.undo_button.get_rect()))
	assert_true(r.intersects(Rect2(400, 270, 50, 50)))


## CHECK: 6
func test_restart_button_no_overlap_settings_button() -> void:
	var m = await _start()
	var r := Rect2(m.hud.restart_button.position, m.hud.restart_button.size)
	assert_false(r.intersects(m.hud.settings_button.get_rect()))
	assert_true(r.intersects(Rect2(400, 270, 50, 50)))


## CHECK: 7
func test_restart_button_no_overlap_board() -> void:
	var m = await _start()
	var r := Rect2(m.hud.restart_button.position, m.hud.restart_button.size)
	assert_false(r.intersects(m.board_view.board_rect()))
	assert_true(r.intersects(Rect2(400, 270, 50, 50)))


## CHECK: 8
func test_restart_signal_resets_board() -> void:
	var m = await _start()
	m.session.tap(0, 0)
	assert_eq(m.session.snapshot()["board"]["marks"], 1)
	m.hud.restart_pressed.emit()
	assert_eq(m.session.snapshot()["board"]["marks"], 0)
	assert_eq(m.session.snapshot()["board"]["pieces"], 0)


## CHECK: 9
func test_restart_signal_keeps_level_and_status() -> void:
	var m = await _start()
	m.session.tap(0, 0)
	m.hud.restart_pressed.emit()
	assert_eq(m.session.snapshot()["level"], 1)
	assert_eq(m.session.snapshot()["status"], "playing")


## CHECK: 10
func test_restart_button_press_resets_board() -> void:
	var m = await _start()
	m.session.tap(0, 0)
	assert_eq(m.session.snapshot()["board"]["marks"], 1)
	m.hud.restart_button.pressed.emit()
	assert_eq(m.session.snapshot()["board"]["marks"], 0)
	assert_eq(m.session.snapshot()["board"]["pieces"], 0)
