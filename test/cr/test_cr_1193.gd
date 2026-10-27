extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_level() -> Level:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"radar": [[0, 0, 1]],
		"asteroids": [[3, 3]]
	})
	return level


func _make_main() -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([_make_level()])
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _cell_pos(m: Node, x: int, y: int) -> Vector2:
	return m.board_view.global_position + m.board_view.cell_rect(x, y).get_center()


func _touch_down(m: Node, pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = true
	ev.position = pos
	m._input(ev)


func _touch_up(m: Node, pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = false
	ev.position = pos
	m._input(ev)


## CHECK: 1
func test_cr_1193_check_1() -> void:
	var m = await _make_main()
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])

	assert_true(m.rock_ng(0, 0))
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])

	assert_true(m.rock_ng(3, 3))
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.sound.vibrations, [250, 250])

	assert_false(m.rock_ng(1, 0))
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 2
func test_cr_1193_check_2() -> void:
	var m = await _make_main()

	var p00 = _cell_pos(m, 0, 0)
	_touch_down(m, p00)
	_touch_up(m, p00)
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.moves, 0)

	var p10 = _cell_pos(m, 1, 0)
	_touch_down(m, p10)
	_touch_up(m, p10)
	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])


## CHECK: 3
func test_cr_1193_check_3() -> void:
	var m = await _make_main()

	var p33 = _cell_pos(m, 3, 3)
	_touch_down(m, p33)
	_touch_up(m, p33)
	_touch_down(m, p33)
	_touch_up(m, p33)

	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 4
func test_cr_1193_check_4() -> void:
	var m = await _make_main()

	var p00 = _cell_pos(m, 0, 0)
	_touch_down(m, p00)
	_touch_up(m, p00)
	assert_eq(m.sound.played, ["wrong"])

	var p01 = _cell_pos(m, 0, 1)
	var p10 = _cell_pos(m, 1, 0)

	_touch_down(m, p01)

	var drag1 := InputEventScreenDrag.new()
	drag1.index = 0
	drag1.position = p00
	m._input(drag1)

	var drag2 := InputEventScreenDrag.new()
	drag2.index = 0
	drag2.position = p10
	m._input(drag2)

	_touch_up(m, p10)

	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(0, 1), 1)
	assert_eq(m.session.board.state_at(1, 0), 1)
