extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const Rules = preload("res://core/rules.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_tutorial_place_sound() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.sound.played[-1], "place")


## CHECK: 2
func test_tutorial_mark_sound() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	m.tutorial_input("next", Vector2i(-1, -1))
	m.tutorial_input("tap", Vector2i(2, 0))
	assert_eq(m.sound.played[-1], "mark")


## CHECK: 3
func test_tutorial_wrong_sound() -> void:
	var m = await _start()
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	m.tutorial_input("next", Vector2i(-1, -1))
	m.tutorial_input("tap", Vector2i(2, 0))
	m.tutorial_input("tap", Vector2i(2, 2))
	m.tutorial_input("double_tap", Vector2i(0, 2))
	m.tutorial_input("double_tap", Vector2i(1, 3))
	assert_eq(m.sound.played[-1], "wrong")


## CHECK: 4
func test_tutorial_init_last_values() -> void:
	var m = await _start()
	m.start_tutorial()
	assert_eq(m.last_snapshot, m.tutorial.session.snapshot())
	assert_eq(m.last_conflicts, Rules.conflicts(m.tutorial.session.board, m.tutorial.session.level).size())
