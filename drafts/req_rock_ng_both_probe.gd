extends GutTest
# 岩（数字付きの岩・数字の無い岩）をタップ・ダブルタップしたら NG の音と振動を 1 回出す直しの確かめる項目を GUT にした見本（req_rock_ng_both.txt の項目 1〜4 と同じ順）。


func _main():
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]})
	var m = load("res://scenes/main.tscn").instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _pos(m, x: int, y: int) -> Vector2:
	return m.board_view.global_position + m.board_view.cell_rect(x, y).get_center()


## CHECK: 1
func test_rock_ng_on_radar_and_asteroid() -> void:
	var m = await _main()
	assert_eq(m.rock_ng(0, 0), true)
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.rock_ng(3, 3), true)
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.sound.vibrations, [250, 250])
	assert_eq(m.rock_ng(1, 0), false)
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 2
func test_tap_on_rock_by_touch() -> void:
	var m = await _main()
	m._on_touch_down(_pos(m, 0, 0))
	m._on_touch_up(_pos(m, 0, 0))
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.moves, 0)
	m._on_touch_down(_pos(m, 1, 0))
	m._on_touch_up(_pos(m, 1, 0))
	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])


## CHECK: 3
func test_double_tap_on_rock_rings_once() -> void:
	var m = await _main()
	m._on_touch_down(_pos(m, 3, 3))
	m._on_touch_up(_pos(m, 3, 3))
	m._on_touch_down(_pos(m, 3, 3))
	m._on_touch_up(_pos(m, 3, 3))
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 4
func test_swipe_over_rock_no_ng() -> void:
	var m = await _main()
	m._on_touch_down(_pos(m, 0, 0))
	m._on_touch_up(_pos(m, 0, 0))
	assert_eq(m.sound.played, ["wrong"])
	m._on_touch_down(_pos(m, 0, 1))
	var drag1 = InputEventScreenDrag.new()
	drag1.index = 0
	drag1.position = _pos(m, 0, 0)
	m._input(drag1)
	var drag2 = InputEventScreenDrag.new()
	drag2.index = 0
	drag2.position = _pos(m, 1, 0)
	m._input(drag2)
	m._on_touch_up(_pos(m, 1, 0))
	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(0, 1), 1)
	assert_eq(m.session.board.state_at(1, 0), 1)
