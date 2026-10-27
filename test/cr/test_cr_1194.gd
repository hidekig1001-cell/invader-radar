extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_levels() -> Array:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	return [l1, l2, l3]


func _start_main(language: String) -> Node:
	var levels = _make_levels()
	var m = MainScene.instantiate()
	m.language = language
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1194_size_up_tile_text_ja() -> void:
	var m = await _start_main("ja")
	m.session.solve_now()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	m.tick_size_up(0.7)
	assert_eq(m.size_up_tile_text(), "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)


## CHECK: 2
func test_cr_1194_size_up_tile_text_en() -> void:
	var m = await _start_main("en")
	m.session.solve_now()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	m.tick_size_up(0.7)
	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)
