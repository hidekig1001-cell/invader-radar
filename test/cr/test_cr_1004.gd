extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start() -> Node2D:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_rules_label_exists_and_is_label() -> void:
	var m = await _start()
	assert_not_null(m.rules_label)
	assert_true(m.rules_label is Label)


## CHECK: 2
func test_rules_label_text_matches_spec() -> void:
	var m = await _start()
	var expected_text := "ONE PIECE PER ROW, COLUMN AND COLOR.\nPIECES MUST NOT TOUCH, EVEN DIAGONALLY."
	assert_eq(m.rules_label.text, expected_text)


## CHECK: 3
func test_rules_label_is_visible() -> void:
	var m = await _start()
	assert_true(m.rules_label.visible)


## CHECK: 4
func test_rules_label_does_not_overlap_board() -> void:
	var m = await _start()
	var label_rect: Rect2 = m.rules_label.get_global_rect()
	var board_rect: Rect2 = m.board_view.board_rect()
	assert_false(label_rect.intersects(board_rect))
