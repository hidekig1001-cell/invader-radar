extends GutTest

const HudScript = preload("res://scenes/hud.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_hud():
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	return hud


## CHECK: 1
func test_cr_1092_hud_tutorial_mode_disables_buttons() -> void:
	var hud = await _make_hud()
	var snap = {"level": 1, "score": 0, "hints": 3, "moves": 0, "status": "playing"}

	hud.set_tutorial_mode(true)
	hud.update_from(snap)
	assert_true(hud.hint_button.disabled)
	assert_true(hud.undo_button.disabled)

	hud.set_tutorial_mode(false)
	hud.update_from(snap)
	assert_false(hud.hint_button.disabled)
	assert_false(hud.undo_button.disabled)


## CHECK: 2
func test_cr_1092_main_tutorial_blocks_hint() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_true(m.hud.hint_button.disabled)

	var h0 = m.session.hints
	m.hud.hint_pressed.emit()
	assert_eq(m.session.hints, h0)
	assert_true(m.session.current_hint.is_empty())
	assert_eq(m.board_view.hint_cell, Vector2i(-1, -1))
