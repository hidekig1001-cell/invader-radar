extends GutTest
# Pixel 指摘の続き（改修18）: 吹き出しが hud のボタン・盤に重ならないこと。

const MainScene = preload("res://scenes/main.tscn")
const BubbleScript = preload("res://scenes/message_bubble.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")

const SCREEN_SIZES := [Vector2(1080, 2424), Vector2(1080, 1920)]
const BUTTON_GAP := 8.0
const HINT_TEXTS_EN := [
	"THIS CELL IS MARKED BY MISTAKE. TAP TO REMOVE THE X.",
	"THIS PIECE IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT.",
	"A PIECE GOES HERE. DOUBLE TAP TO PLACE IT.",
]


func _start_main(lang: String):
	var m = MainScene.instantiate()
	m.language = lang
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _board_global_rect(m) -> Rect2:
	var r: Rect2 = m.board_view.board_bg_rect()
	return Rect2(m.board_view.global_position + r.position, r.size)


func _assert_bubble_clear_of_parts(m, label: String) -> void:
	assert_true(m.bubble.visible, label)
	var b: Rect2 = m.bubble.get_global_rect()
	var undo_r: Rect2 = m.hud.undo_button.get_global_rect()
	var restart_r: Rect2 = m.hud.restart_button.get_global_rect()
	var sound_r: Rect2 = m.hud.sound_button.get_global_rect()
	var board_r: Rect2 = _board_global_rect(m)
	assert_false(b.intersects(undo_r), label + " undo")
	assert_false(b.intersects(restart_r), label + " restart")
	assert_false(b.intersects(sound_r), label + " sound")
	assert_false(b.intersects(board_r), label + " board")
	assert_true(b.position.y >= undo_r.end.y + BUTTON_GAP, label + " gap below undo")
	assert_true(b.position.y >= restart_r.end.y + BUTTON_GAP, label + " gap below restart")
	assert_true(b.end.y <= board_r.position.y, label + " above board")


## CHECK: 1
func test_bubble_does_not_overlap_buttons_or_board() -> void:
	for lang in ["en", "ja"]:
		for screen in SCREEN_SIZES:
			var m = await _start_main(lang)
			m.apply_screen_layout(screen)
			await wait_frames(1)
			var tag: String = lang + " " + str(screen)

			_assert_bubble_clear_of_parts(m, tag + " help")

			m.hud.hint_button.pressed.emit()
			await wait_frames(1)
			_assert_bubble_clear_of_parts(m, tag + " hint")

			for en_text in HINT_TEXTS_EN:
				var t: String = m.hint_text(en_text)
				m.bubble.show_text(t, 0.0)
				await wait_frames(1)
				_assert_bubble_clear_of_parts(m, tag + " hint text " + t)

			m.start_tutorial()
			await wait_frames(1)
			for i in range(TutorialSteps.steps().size()):
				m.bubble.show_panel(TutorialSteps.apply_language(lang, i))
				await wait_frames(1)
				_assert_bubble_clear_of_parts(m, tag + " tutorial step " + str(i))
			m.end_tutorial()
			await wait_frames(1)
			_assert_bubble_clear_of_parts(m, tag + " after tutorial")
