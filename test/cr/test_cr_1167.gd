extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MS = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1167_size_up_text_ja() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
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

	assert_eq(m.help_text(), "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")

	s.next_level()
	m.show_help()
	await wait_frames(1)

	assert_eq(m.help_text(), "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
	assert_eq(m.bubble.text, "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
	assert_eq(m.bubble.get_line_count(), 2)

	s.next_level()
	assert_eq(m.help_text(), "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")

## CHECK: 2
func test_cr_1167_size_up_text_en() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var s = SessionScript.new([l1, l2, l3])
	var m = MS.instantiate()
	m.language = "en"
	m.session = s
	add_child_autofree(m)
	await wait_frames(2)

	s.next_level()
	m.show_help()
	await wait_frames(1)

	assert_eq(m.size_up_text(), "THE BOARD IS 5x5 FROM HERE. GOOD LUCK!")
	assert_eq(m.bubble.text, "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X")
	assert_eq(m.bubble.get_line_count(), 2)
