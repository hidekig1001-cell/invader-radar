# scenes/main.tscn を立ち上げて、session が読めることと、表示が session に追随することを確かめる。
extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


func test_main_has_session() -> void:
	var m = await _start()
	assert_not_null(m.session)
	assert_eq(m.session.snapshot()["level"], 1)


func test_hud_follows_session() -> void:
	var m = await _start()
	assert_eq(m.hud.level_label.text, "1")
	assert_eq(m.hud.hint_label.text, "3")
	m.session.use_hint()
	assert_eq(m.hud.hint_label.text, "2")


func test_geometry_fits_the_screen() -> void:
	var m = await _start()
	var g: Dictionary = m.board_view.geometry()
	assert_eq(g["w"], 4)
	assert_eq(g["h"], 4)
	var r: Rect2 = m.board_view.board_rect()
	assert_true(Rect2(0, 0, 1080, 1920).encloses(r))


func test_touch_gestures_reach_session() -> void:
	var m = await _start()
	var c: Vector2 = m.board_view.cell_rect(1, 2).get_center()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = c
	m._input(down)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = c
	m._input(up)
	assert_eq(m.session.board.snapshot()["rows"][2], ".x..")
