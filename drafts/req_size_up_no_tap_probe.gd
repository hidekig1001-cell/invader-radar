extends GutTest
# 盤が大きくなる面のお知らせから「タップではじめる」を消す直しの確かめる項目を GUT にした見本（req_size_up_no_tap.txt の項目 1・2 と同じ順）。


func _main(lang: String):
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var m = load("res://scenes/main.tscn").instantiate()
	m.language = lang
	m.session = SessionScript.new([l1, l2, l3])
	add_child_autofree(m)
	await wait_frames(2)
	m.session.solve_now()
	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	m.tick_size_up(0.7)
	return m


## CHECK: 1
func test_size_up_text_ja_without_tap() -> void:
	var m = await _main("ja")
	assert_eq(m.size_up_tile_text(), "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)


## CHECK: 2
func test_size_up_text_en_without_tap() -> void:
	var m = await _main("en")
	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)
