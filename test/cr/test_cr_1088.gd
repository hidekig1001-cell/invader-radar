extends GutTest

const Hud = preload("res://scenes/hud.gd")


func _start():
	var hud = Hud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	return hud


## CHECK: 1
func test_cr_1088_level_name_label_padding() -> void:
	var hud = await _start()
	var c = Hud.table_cell_rect(0, 0)
	assert_almost_eq(hud.level_name_label.position.x, c.position.x + 16.0, 0.01)
	assert_almost_eq(hud.level_name_label.size.x, c.size.x - 32.0, 0.01)
	assert_almost_eq(hud.level_name_label.position.y, c.position.y, 0.01)


## CHECK: 2
func test_cr_1088_time_labels_padding() -> void:
	var hud = await _start()
	var c = Hud.table_cell_rect(2, 1)
	assert_almost_eq(hud.time_label.position.x, c.position.x + 16.0, 0.01)
	assert_almost_eq(hud.time_label.size.x, c.size.x - 32.0, 0.01)
	assert_almost_eq(hud.time_name_label.position.x, c.position.x + 16.0, 0.01)


## CHECK: 3
func test_cr_1088_gap_between_cells() -> void:
	var hud = await _start()
	assert_almost_eq(hud.score_name_label.position.x - (hud.level_label.position.x + hud.level_label.size.x), 32.0, 0.01)
	assert_almost_eq(hud.hint_name_label.position.x - (hud.score_label.position.x + hud.score_label.size.x), 32.0, 0.01)
	assert_almost_eq(hud.time_name_label.position.x - (hud.moves_label.position.x + hud.moves_label.size.x), 32.0, 0.01)
