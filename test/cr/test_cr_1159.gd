extends GutTest

const MainScene = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1159_help_text_en() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.help_text(), "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X")
	assert_eq(m.bubble.text, "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X")

## CHECK: 1
func test_cr_1159_help_text_ja() -> void:
	var n = MainScene.instantiate()
	n.language = "ja"
	add_child_autofree(n)
	await wait_frames(2)
	assert_eq(n.help_text(), "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
	assert_eq(n.bubble.text, "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")
