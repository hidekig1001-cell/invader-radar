extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_moves_label_text_matches_session_moves() -> void:
	var m = await _start()
	assert_eq(m.hud.moves_label.text, str(m.session.moves))


## CHECK: 2
func test_update_from_sets_moves_label_for_1_move() -> void:
	var m = await _start()
	m.session.moves = 1
	m.hud.update_from(m.session.snapshot())
	assert_eq(m.hud.moves_label.text, "1")


## CHECK: 3
func test_update_from_sets_moves_label_for_5_moves() -> void:
	var m = await _start()
	m.session.moves = 5
	m.hud.update_from(m.session.snapshot())
	assert_eq(m.hud.moves_label.text, "5")
