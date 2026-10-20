extends GutTest

const Hud = preload("res://scenes/hud.gd")


func _make_hud() -> Node:
	var hud = Hud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	return hud


## CHECK: 1
func test_cr_1087_name_labels_localized() -> void:
	var hud = await _make_hud()
	hud.set_language("ja")
	assert_eq(hud.level_name_label.text, "レベル")
	assert_eq(hud.score_name_label.text, "スコア")
	assert_eq(hud.hint_name_label.text, "残りヒント")
	assert_eq(hud.moves_name_label.text, "手数")
	assert_eq(hud.time_name_label.text, "経過時間")
	hud.set_language("en")
	assert_eq(hud.level_name_label.text, "LEVEL")
	assert_eq(hud.score_name_label.text, "SCORE")
	assert_eq(hud.hint_name_label.text, "HINTS LEFT")
	assert_eq(hud.moves_name_label.text, "MOVES")
	assert_eq(hud.time_name_label.text, "TIME")


## CHECK: 2
func test_cr_1087_value_labels_only_numbers() -> void:
	var hud = await _make_hud()
	hud.update_from({"level": 7, "score": 120, "hints": 2, "moves": 9, "status": "playing"})
	assert_eq(hud.level_label.text, "7")
	assert_eq(hud.score_label.text, "120")
	assert_eq(hud.hint_label.text, "2")
	assert_eq(hud.moves_label.text, "9")
	hud.set_time(65.0)
	assert_eq(hud.time_label.text, "1:05")


## CHECK: 3
func test_cr_1087_table_cell_rect_and_positions() -> void:
	var hud = await _make_hud()
	assert_eq(Hud.table_cell_rect(0, 0), Rect2(40, 90, 1000.0 / 3.0, 80))
	assert_eq(Hud.table_cell_rect(2, 1).position.y, 170.0)
	assert_eq(hud.level_label.position.y, 90.0)
	assert_eq(hud.moves_label.position.y, 170.0)
	assert_eq(hud.time_label.position.y, 170.0)
	assert_true(hud.time_label.position.x > hud.moves_label.position.x)
