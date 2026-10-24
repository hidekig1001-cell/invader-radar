extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")

## CHECK: 1
func test_mark_color_at_and_radar_text_color() -> void:
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"radar": [[0, 0, 2]], 
		"asteroids": [], 
		"regions": [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
	})
	var s = SessionScript.new([level])
	s.board.apply("mark", 0, 0)
	
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s
	
	assert_true(bv.mark_color_at(0, 0).is_equal_approx(BoardView.MARK_COLOR))
	assert_true(bv.mark_color_at(2, 2).is_equal_approx(BoardView.MARK_COLOR))
	assert_eq(bv.radar_text_color(0, 0), Color(1, 1, 1))
	
	var s2 = SessionScript.new([level])
	s2.board.apply("place", 1, 0)
	s2.board.apply("place", 0, 1)
	s2.board.apply("place", 1, 1)
	bv.session = s2
	
	assert_eq(bv.radar_text_color(0, 0), Color.RED)

## CHECK: 2
func test_radar_outline_properties() -> void:
	var bv = BoardView.new()
	add_child_autofree(bv)
	
	assert_true(bv.radar_outline_color().is_equal_approx(Color(0.12, 0.10, 0.22)))
	assert_eq(bv.radar_outline_size(), 8)
