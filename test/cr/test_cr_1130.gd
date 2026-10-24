extends GutTest

const BV = preload("res://scenes/board_view.gd")
const Lv = preload("res://game/level.gd")
const S = preload("res://game/session.gd")


## CHECK: 1
func test_has_radar_and_mark_color_at_with_session() -> void:
	var level = Lv.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [[0, 0, 2]],
		"asteroids": [],
		"regions": [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
	})
	var s = S.new([level])
	s.board.apply("mark", 0, 0)
	var bv = BV.new()
	add_child_autofree(bv)
	bv.session = s

	assert_true(bv.has_radar(0, 0))
	assert_false(bv.has_radar(2, 2))
	assert_true(bv.mark_color_at(0, 0).is_equal_approx(Color(0.25, 0.22, 0.40)))
	assert_true(bv.mark_color_at(2, 2).is_equal_approx(Color(0.25, 0.22, 0.40)))
	assert_true(bv.radar_text_color(0, 0).is_equal_approx(Color(1, 1, 1)))

	var s2 = S.new([level])
	s2.board.apply("place", 1, 0)
	s2.board.apply("place", 0, 1)
	s2.board.apply("place", 1, 1)
	bv.session = s2
	assert_true(bv.radar_text_color(0, 0).is_equal_approx(Color.RED))


## CHECK: 2
func test_has_radar_and_mark_color_at_without_session() -> void:
	var bv = BV.new()
	add_child_autofree(bv)

	assert_false(bv.has_radar(0, 0))
	assert_true(bv.mark_color_at(0, 0).is_equal_approx(Color(0.25, 0.22, 0.40)))
