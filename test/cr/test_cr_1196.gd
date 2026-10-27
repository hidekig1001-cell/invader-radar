extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")

func _make_level_4x4() -> Level:
	var l = Level.new()
	l.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 0, 0],
			[1, 1, 1, 1],
			[2, 2, 2, 2],
			[3, 3, 3, 3]
		],
		"radar": [[0, 0, 1], [2, 1, 0]],
		"asteroids": [[3, 3], [1, 3]]
	})
	return l

func _make_board_view_with_session(l: Level) -> BoardView:
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = SessionScript.new([l])
	return bv

## CHECK: 1
func test_cr_1196_rock_text_values() -> void:
	var l = _make_level_4x4()
	var bv = _make_board_view_with_session(l)
	
	assert_eq(bv.rock_text(3, 3), "?")
	assert_eq(bv.rock_text(1, 3), "?")
	assert_eq(bv.rock_text(0, 0), "1")
	assert_eq(bv.rock_text(2, 1), "0")
	assert_eq(bv.rock_text(1, 1), "")
	assert_eq(bv.rock_text(3, 0), "")
	
	var bv2 = BoardView.new()
	add_child_autofree(bv2)
	assert_eq(bv2.rock_text(0, 0), "")

## CHECK: 2
func test_cr_1196_rock_text_color_values() -> void:
	var l = _make_level_4x4()
	var bv = _make_board_view_with_session(l)
	
	assert_true(bv.rock_text_color(3, 3).is_equal_approx(Color(1, 1, 1)))
	assert_true(bv.rock_text_color(0, 0).is_equal_approx(Color(1, 1, 1)))
	assert_true(bv.radar_text_color(3, 3).is_equal_approx(BoardView.MARK_COLOR))
	
	bv.session.board.apply("place", 1, 0)
	bv.session.board.apply("place", 0, 1)
	
	assert_true(bv.rock_text_color(0, 0).is_equal_approx(Color.RED))
	assert_eq(bv.rock_text(0, 0), "1")
	assert_true(bv.rock_text_color(3, 3).is_equal_approx(Color(1, 1, 1)))

## CHECK: 3
func test_cr_1196_draw_uses_new_functions() -> void:
	var src: String = load("res://scenes/board_view.gd").source_code
	var start_idx = src.find("func _draw() -> void:")
	assert_true(start_idx >= 0)
	
	var end_idx = src.find("\nfunc ", start_idx + 1)
	if end_idx == -1:
		end_idx = src.length()
		
	var body = src.substr(start_idx, end_idx - start_idx)
	
	assert_true(body.find("rock_text(") >= 0)
	assert_true(body.find("rock_text_color(") >= 0)
	assert_true(body.find("radar_label_center(") >= 0)
	assert_true(body.find("radar_font_size()") >= 0)
	assert_true(body.find("radar_outline_size()") >= 0)

## CHECK: 4
func test_cr_1196_main_integration() -> void:
	var l = _make_level_4x4()
	var l2 = Level.new()
	l2.parse({
		"id": 2,
		"width": 5,
		"height": 5,
		"target": 5,
		"regions": [
			[0, 0, 0, 0, 0],
			[1, 1, 1, 1, 1],
			[2, 2, 2, 2, 2],
			[3, 3, 3, 3, 3],
			[4, 4, 4, 4, 4]
		],
		"radar": [],
		"asteroids": []
	})
	
	var m = load("res://scenes/main.tscn").instantiate()
	m.language = "ja"
	m.session = SessionScript.new([l, l2])
	add_child_autofree(m)
	await wait_frames(2)
	
	assert_eq(m.board_view.rock_text(3, 3), "?")
	assert_eq(m.board_view.rock_text(0, 0), "1")
	assert_true(m.board_view.rock_image_at(3, 3))
	assert_false(m.board_view.is_rock(0, 0))
	
	m.session.next_level()
	
	assert_eq(m.board_view.rock_text(3, 3), "")
	assert_eq(m.board_view.rock_text(0, 0), "")
