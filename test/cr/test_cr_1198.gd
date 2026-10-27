extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")
const Rules = preload("res://core/rules.gd")
const InputMapper = preload("res://scenes/input_mapper.gd")

func _make_level(asteroids: Array = []) -> Level:
	var l = Level.new()
	l.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]],
		"asteroids": asteroids
	})
	return l

func _make_main(asteroids: Array = []) -> Node:
	var m = load("res://scenes/main.tscn").instantiate()
	m.language = "ja"
	m.session = SessionScript.new([_make_level(asteroids)])
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1198_check_1() -> void:
	var m = await _make_main()
	m.session.tap(1, 1)
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	var help0 = m.bubble.text
	
	m.on_board_tap(Vector2i(0, 1))
	
	assert_eq(Rules.dead_marks(m.session.board, m.session.level).size(), 4)
	assert_almost_eq(m.dead_hold, 0.3, 0.001)
	assert_eq(m.board_view.mark_color_at(1, 1), BoardView.MARK_COLOR)
	assert_eq(m.board_view.mark_color_at(0, 1), BoardView.MARK_COLOR)
	assert_eq(m.sound.played[-1], "mark")
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [15, 15, 15, 15])
	assert_eq(m.bubble.text, help0)
	
	m.tick_dead_hold(0.31)
	
	assert_almost_eq(m.dead_hold, 0.0, 0.001)
	assert_eq(m.board_view.held_marks, [])
	assert_eq(m.board_view.mark_color_at(1, 1), Color.RED)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 15, 250])
	assert_ne(m.bubble.text, help0)

## CHECK: 2
func test_cr_1198_check_2() -> void:
	var m = await _make_main()
	m.session.tap(1, 1)
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	var help0 = m.bubble.text
	
	m.on_board_tap(Vector2i(0, 1))
	assert_almost_eq(m.dead_hold, 0.3, 0.001)
	assert_eq(m.board_view.held_marks.size(), 4)
	
	m.session.double_tap(0, 1)
	assert_eq(m.session.board.pieces().size(), 1)
	assert_eq(m.board_view.mark_color_at(1, 1), BoardView.MARK_COLOR)
	assert_eq(m.sound.played.count("dead"), 0)
	
	m.tick_dead_hold(0.31)
	assert_eq(m.board_view.mark_color_at(1, 1), BoardView.MARK_COLOR)
	assert_eq(m.board_view.held_marks, [])
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations.count(250), 0)
	assert_eq(m.bubble.text, help0)

## CHECK: 3
func test_cr_1198_check_3() -> void:
	var m = await _make_main()
	m.session.tap(1, 1)
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	
	m.session.tap(0, 1)
	assert_almost_eq(m.dead_hold, 0.0, 0.001)
	assert_eq(m.board_view.held_marks, [])
	assert_eq(m.board_view.mark_color_at(1, 1), Color.RED)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations[-1], 250)
	
	m.session.tap(0, 1)
	m.on_board_tap(Vector2i(0, 1))
	assert_eq(m.board_view.mark_color_at(1, 1), BoardView.MARK_COLOR)
	assert_almost_eq(m.dead_hold, 0.3, 0.001)
	
	var m2 = await _make_main()
	m2.session.tap(1, 1)
	m2.session.tap(2, 1)
	m2.session.tap(3, 1)
	m2.session.swipe([Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)])
	assert_eq(m2.board_view.mark_color_at(0, 2), Color.RED)
	assert_eq(m2.sound.played[-1], "dead")

## CHECK: 4
func test_cr_1198_check_4() -> void:
	var m = await _make_main([[3, 3]])
	m.session.tap(1, 1)
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	var help0 = m.bubble.text
	
	m.on_board_tap(Vector2i(3, 3))
	assert_eq(m.sound.played[-1], "wrong")
	assert_almost_eq(m.dead_hold, 0.0, 0.001)
	
	m.on_board_tap(Vector2i(0, 1))
	m.tick_dead_hold(0.2)
	assert_eq(m.board_view.mark_color_at(1, 1), BoardView.MARK_COLOR)
	assert_eq(m.sound.played.count("dead"), 0)
	
	m.tick_dead_hold(0.2)
	assert_eq(m.board_view.mark_color_at(1, 1), Color.RED)
	assert_eq(m.sound.played.count("dead"), 1)
	
	var src: String = load("res://scenes/main.gd").source_code
	var start_idx = src.find("func _on_touch_up(")
	var end_idx = src.find("\nfunc ", start_idx + 1)
	var body = src.substr(start_idx, end_idx - start_idx)
	assert_true(body.find("on_board_tap(c)") >= 0)
	assert_false(body.find("session.tap(") >= 0)
