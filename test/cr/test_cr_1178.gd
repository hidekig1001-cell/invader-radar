extends GutTest

## CHECK: 1
func test_cr_1178_size_up_wait_and_age() -> void:
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var MS = load("res://scenes/main.tscn")

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

	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)

	m._input(down)

	assert_eq(s.level_index, 1)
	assert_false(m.bubble.tile_mode)
	assert_eq(m.size_up_wait, 0.6)

	m.tick_size_up(0.7)

	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")

	m._input(down)

	assert_true(m.bubble.tile_mode)

	m.tick_size_up(1.0)
	m._input(down)

	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, m.help_text())
