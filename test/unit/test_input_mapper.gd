# scenes/input_mapper.gd（Node に触れない関数）の単体テスト。盤は原点 (100, 200)、1 マス 100px、4x4。
extends GutTest

const InputMapper = preload("res://scenes/input_mapper.gd")

const GEOM := {"origin": Vector2(100, 200), "cell": 100.0, "w": 4, "h": 4}


# マス (cx, cy) の中心から少しずらした位置
func _at(cx: int, cy: int, dx: float = 0.0, dy: float = 0.0) -> Vector2:
	return Vector2(100 + cx * 100 + 50 + dx, 200 + cy * 100 + 50 + dy)


func _pt(pos: Vector2, t: int) -> Dictionary:
	return {"pos": pos, "t": t}


func _tap_stroke(cx: int, cy: int, t: int) -> Array:
	return [_pt(_at(cx, cy), t), _pt(_at(cx, cy, 3.0, 2.0), t + 60)]


func test_cell_at() -> void:
	assert_eq(InputMapper.cell_at(Vector2(100, 200), GEOM), Vector2i(0, 0))
	assert_eq(InputMapper.cell_at(Vector2(199, 299), GEOM), Vector2i(0, 0))
	assert_eq(InputMapper.cell_at(Vector2(200, 200), GEOM), Vector2i(1, 0))
	assert_eq(InputMapper.cell_at(Vector2(499, 599), GEOM), Vector2i(3, 3))


func test_cell_at_outside_board() -> void:
	assert_eq(InputMapper.cell_at(Vector2(99, 250), GEOM), InputMapper.NO_CELL)
	assert_eq(InputMapper.cell_at(Vector2(150, 199), GEOM), InputMapper.NO_CELL)
	assert_eq(InputMapper.cell_at(Vector2(500, 250), GEOM), InputMapper.NO_CELL)
	assert_eq(InputMapper.cell_at(Vector2(150, 600), GEOM), InputMapper.NO_CELL)


func test_single_tap() -> void:
	var r := InputMapper.classify(_tap_stroke(2, 1, 1000), {}, GEOM)
	assert_eq(r["kind"], "tap")
	assert_eq(r["cell"], Vector2i(2, 1))
	assert_eq(r["tap_record"]["cell"], Vector2i(2, 1))
	assert_eq(r["tap_record"]["t"], 1060)


func test_double_tap_within_300ms_on_same_cell() -> void:
	var out := InputMapper.map_all([_tap_stroke(1, 1, 1000), _tap_stroke(1, 1, 1200)], GEOM)
	assert_eq(out.size(), 2)
	assert_eq(out[0]["kind"], "tap")
	assert_eq(out[1]["kind"], "double_tap")
	assert_eq(out[1]["cell"], Vector2i(1, 1))


func test_second_tap_too_late_is_a_plain_tap() -> void:
	# 1 回目は離した時刻 1060、2 回目は 1060 + 301 = 1361 で離す
	var out := InputMapper.map_all([_tap_stroke(1, 1, 1000), _tap_stroke(1, 1, 1301)], GEOM)
	assert_eq(out[1]["kind"], "tap")


func test_exactly_300ms_counts_as_double_tap() -> void:
	var out := InputMapper.map_all([_tap_stroke(1, 1, 1000), _tap_stroke(1, 1, 1300)], GEOM)
	assert_eq(out[1]["kind"], "double_tap")


func test_second_tap_on_other_cell_is_a_plain_tap() -> void:
	var out := InputMapper.map_all([_tap_stroke(1, 1, 1000), _tap_stroke(2, 1, 1100)], GEOM)
	assert_eq(out[0]["kind"], "tap")
	assert_eq(out[1]["kind"], "tap")
	assert_eq(out[1]["cell"], Vector2i(2, 1))


func test_third_tap_is_not_another_double_tap() -> void:
	var out := InputMapper.map_all([_tap_stroke(0, 0, 1000), _tap_stroke(0, 0, 1100), _tap_stroke(0, 0, 1200)], GEOM)
	assert_eq(out[0]["kind"], "tap")
	assert_eq(out[1]["kind"], "double_tap")
	assert_eq(out[2]["kind"], "tap")


func test_swipe_collects_cells_in_order() -> void:
	var stroke := [_pt(_at(0, 2), 1000), _pt(_at(1, 2), 1050), _pt(_at(2, 2), 1100), _pt(_at(3, 2), 1150)]
	var r := InputMapper.classify(stroke, {}, GEOM)
	assert_eq(r["kind"], "swipe")
	assert_eq(r["cells"], [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)])
	assert_true(r["tap_record"].is_empty())


func test_fast_swipe_does_not_skip_cells() -> void:
	# 2 点だけ（始まりと終わり）でも、間のマスを拾う
	var stroke := [_pt(_at(0, 0), 1000), _pt(_at(3, 0), 1040)]
	var r := InputMapper.classify(stroke, {}, GEOM)
	assert_eq(r["kind"], "swipe")
	assert_eq(r["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_swipe_leaving_the_board_keeps_only_board_cells() -> void:
	var stroke := [_pt(_at(2, 3), 1000), _pt(_at(3, 3), 1050), _pt(Vector2(700, 550), 1100)]
	var r := InputMapper.classify(stroke, {}, GEOM)
	assert_eq(r["kind"], "swipe")
	assert_eq(r["cells"], [Vector2i(2, 3), Vector2i(3, 3)])


func test_small_wiggle_is_still_a_tap() -> void:
	var stroke := [_pt(_at(1, 1), 1000), _pt(_at(1, 1, 15.0, -10.0), 1030), _pt(_at(1, 1, -5.0, 8.0), 1080)]
	assert_eq(InputMapper.classify(stroke, {}, GEOM)["kind"], "tap")


func test_swipe_breaks_double_tap_chain() -> void:
	var swipe := [_pt(_at(0, 0), 1100), _pt(_at(2, 0), 1140)]
	var out := InputMapper.map_all([_tap_stroke(1, 1, 1000), swipe, _tap_stroke(1, 1, 1180)], GEOM)
	assert_eq(out[2]["kind"], "tap")


func test_touch_outside_board_is_ignored() -> void:
	var stroke := [_pt(Vector2(20, 20), 1000), _pt(Vector2(22, 21), 1050)]
	assert_eq(InputMapper.classify(stroke, {}, GEOM)["kind"], "none")
	assert_eq(InputMapper.map_all([stroke], GEOM).size(), 0)
	assert_eq(InputMapper.classify([], {}, GEOM)["kind"], "none")
