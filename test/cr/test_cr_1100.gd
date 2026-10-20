extends GutTest

const MainScene = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr1100_1_last_level_clear_and_title() -> void:
	var m = MainScene.instantiate()
	m.language = "en"
	add_child_autofree(m)
	await wait_frames(2)
	
	var last = m.session.levels.size() - 1
	m.session.restore_dict({"level_index": last, "score": 0, "hints": 3})
	m.session.solve_now()
	await wait_frames(1)
	
	assert_eq(m.session.status, "cleared")
	assert_eq(m.cleared_text(), "ALL LEVELS CLEARED!  TAP FOR TITLE")
	assert_eq(m.bubble.text, "ALL LEVELS CLEARED!  TAP FOR TITLE")
	
	watch_signals(m)
	m._on_touch_down(Vector2(540, 900))
	assert_signal_emitted(m, "title_requested")
	assert_eq(m.session.level_index, 0)
	
	var n = MainScene.instantiate()
	n.language = "en"
	add_child_autofree(n)
	await wait_frames(2)
	n.session.solve_now()
	await wait_frames(1)
	
	assert_eq(n.cleared_text(), "LEVEL CLEARED!  TAP FOR NEXT")
	watch_signals(n)
	n._on_touch_down(Vector2(540, 900))
	assert_signal_not_emitted(n, "title_requested")
	assert_eq(n.session.level_index, 1)

## CHECK: 2
func test_cr1100_2_last_level_clear_ja() -> void:
	var m = MainScene.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	
	var last = m.session.levels.size() - 1
	m.session.restore_dict({"level_index": last, "score": 0, "hints": 3})
	m.session.solve_now()
	await wait_frames(1)
	
	assert_eq(m.cleared_text(), "全部の面をクリア！  タップでタイトルへ")
	assert_eq(m.bubble.text, "全部の面をクリア！  タップでタイトルへ")
