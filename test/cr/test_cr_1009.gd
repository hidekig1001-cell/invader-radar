extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_rules_label_font_size_and_bounds() -> void:
	var m = await _start()
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 32)
	assert_true(Rect2(0, 0, 1080, 1920).encloses(m.rules_label.get_global_rect()))


## CHECK: 2
func test_rules_label_position_and_size() -> void:
	var m = await _start()
	assert_eq(m.rules_label.position, Vector2(54, 1732))
	assert_eq(m.rules_label.size, Vector2(972, 128))
