extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MS = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1172_size_up_tile_ja() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var s = SessionScript.new([l1, l2, l3])
	var m = MS.instantiate()
	m.language = "ja"
	m.session = s
	add_child_autofree(m)
	await wait_frames(2)
	s.solve_now()
	await wait_frames(1)
	s.next_level()
	await wait_frames(1)
	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる")
	assert_eq(m.bubble.get_line_count(), 2)
	assert_eq(m.help_text(), "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	await wait_frames(1)
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
	assert_eq(s.level_index, 1)
	s.next_level()
	assert_eq(m.size_up_tile_text(), "")

## CHECK: 2
func test_cr_1172_size_up_tile_en() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var s = SessionScript.new([l1, l2, l3])
	var m = MS.instantiate()
	m.session = s
	add_child_autofree(m)
	await wait_frames(2)
	s.solve_now()
	await wait_frames(1)
	s.next_level()
	await wait_frames(1)
	assert_true(m.bubble.tile_mode)
	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START")
	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START")
	assert_eq(m.bubble.get_line_count(), 2)
