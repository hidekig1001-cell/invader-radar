extends GutTest

## CHECK: 1
func test_hint_text_ja_alien() -> void:
	var MS = load("res://scenes/main.tscn")
	var m = MS.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.hint_text("THIS ALIEN IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT."), "この宇宙人の場所はまちがい。ダブルタップで消す。")
	assert_eq(m.hint_text("AN ALIEN GOES HERE. DOUBLE TAP TO PLACE IT."), "ここに宇宙人が入る。ダブルタップで置く。")

## CHECK: 2
func test_hint_button_shows_alien_text() -> void:
	var MS = load("res://scenes/main.tscn")
	var m = MS.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	assert_eq(m.bubble.text, "AN ALIEN GOES HERE. DOUBLE TAP TO PLACE IT.")
