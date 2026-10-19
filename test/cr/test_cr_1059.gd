extends GutTest

const TitleScreen = preload("res://scenes/title_screen.gd")

## CHECK: 1
func test_cr_1059_select_language_ja_fresh_text() -> void:
	var ts = TitleScreen.new()
	add_child_autofree(ts)
	ts.select_language("ja")
	assert_eq(ts._start_btn_fresh.text, "1面からやり直す")
