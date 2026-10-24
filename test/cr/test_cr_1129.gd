extends GutTest

const TitleScreenScript = preload("res://scenes/title_screen.gd")
const MainScene = preload("res://scenes/main.tscn")


## CHECK: 1
func test_title_screen_safe_top() -> void:
	var t = TitleScreenScript.new()
	add_child_autofree(t)
	await wait_frames(2)

	assert_eq(t.safe_top, 0.0)

	t.safe_top = 300.0
	t.apply_screen_layout(Vector2(1080, 2000))
	assert_eq(t.sound_btn.position, Vector2(570, 1160))

	t.safe_top = 0.0
	t.apply_screen_layout(Vector2(1080, 2000))
	assert_eq(t.sound_btn.position, Vector2(570, 1120))


## CHECK: 2
func test_main_safe_top() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	m.apply_screen_layout(Vector2(1080, 1920))
	var p0 = m.hud.position

	m.safe_top = 300.0
	m.apply_screen_layout(Vector2(1080, 2000))
	assert_eq(m.hud.position, p0 + Vector2(0, 80))

	m.safe_top = 0.0
	m.apply_screen_layout(Vector2(1080, 2000))
	assert_eq(m.hud.position, p0 + Vector2(0, 40))
