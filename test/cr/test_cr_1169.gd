extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")


## CHECK: 1
func test_piece_pop_scale_and_scaled_rect() -> void:
	var bv = BoardView.new()
	add_child_autofree(bv)

	# piece_pop_start に時刻を入れる
	bv.piece_pop_start[Vector2i(1, 1)] = 10.0

	# t = 0 のとき (now == start) -> 1.0
	assert_eq(bv.piece_pop_scale(1, 1, 10.0), 1.0)

	# t = 0.5 のとき (now = start + PIECE_POP_TIME/2) -> 1.2
	# PIECE_POP_TIME は 0.15 なので、半分の 0.075 を足す
	assert_almost_eq(bv.piece_pop_scale(1, 1, 10.075), 1.2, 0.0001)

	# t = 1 のとき (now = start + PIECE_POP_TIME) -> 1.0
	assert_eq(bv.piece_pop_scale(1, 1, 10.2), 1.0)

	# piece_pop_start に無いマス -> 1.0
	assert_eq(bv.piece_pop_scale(2, 2, 10.075), 1.0)

	# scaled_rect の確認
	var r = Rect2(0, 0, 100, 100)
	var s = 1.2
	var expected = Rect2(-10, -10, 120, 120)
	assert_true(bv.scaled_rect(r, s).is_equal_approx(expected))


## CHECK: 2
func test_piece_pop_start_updated_on_place_and_clear() -> void:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		]
	})

	var s = SessionScript.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s

	# 駒を置く
	s.board.apply("place", 1, 1)

	# piece_pose を呼ぶと、piece_pop_start に時刻が入るはず
	bv.piece_pose(1, 1)
	assert_true(bv.piece_pop_start.has(Vector2i(1, 1)))

	# 駒を消す
	s.board.apply("clear", 1, 1)

	# forget_empty_poses を呼ぶと、piece_pop_start から消えるはず
	bv.forget_empty_poses()
	assert_false(bv.piece_pop_start.has(Vector2i(1, 1)))
