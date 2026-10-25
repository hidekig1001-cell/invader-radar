extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const LevelScript = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")

## CHECK: 1
func test_cr_1174_dead_marks_warning() -> void:
	var level = LevelScript.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)

	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.bubble.text, "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X")

	m.session.tap(1, 1)
	assert_eq(m.bubble.text, "A LINE OR COLOR HAS ONLY X\nTAP AN X TO REMOVE IT")
	assert_eq(m.help_text(), "A LINE OR COLOR HAS ONLY X\nTAP AN X TO REMOVE IT")

	m.session.tap(1, 1)
	assert_eq(m.bubble.text, "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X")

## CHECK: 2
func test_cr_1174_dead_marks_text_language() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	m.language = "ja"
	assert_eq(m.dead_marks_text(), "× だけの色・行・列があるよ\n× をタップして消してね")

	m.language = "en"
	assert_eq(m.dead_marks_text(), "A LINE OR COLOR HAS ONLY X\nTAP AN X TO REMOVE IT")
