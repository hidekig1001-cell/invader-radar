extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_hint_text_ja_translation() -> void:
	var m = await _start()
	m.language = "ja"
	assert_eq(m.hint_text("THIS CELL IS MARKED BY MISTAKE. TAP TO REMOVE THE X."), "このマスの × はまちがい。タップで × を消す。")
	assert_eq(m.hint_text("THIS PIECE IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT."), "この駒の場所はまちがい。ダブルタップで消す。")
	assert_eq(m.hint_text("A PIECE GOES HERE. DOUBLE TAP TO PLACE IT."), "ここに駒が入る。ダブルタップで置く。")
	assert_eq(m.hint_text("ABC"), "ABC")


## CHECK: 2
func test_hint_text_en_passthrough() -> void:
	var m = await _start()
	m.language = "en"
	assert_eq(m.hint_text("A PIECE GOES HERE. DOUBLE TAP TO PLACE IT."), "A PIECE GOES HERE. DOUBLE TAP TO PLACE IT.")


## CHECK: 3
func test_hint_bubble_shows_ja_text() -> void:
	var m = await _start()
	m.language = "ja"
	m.hud.hint_pressed.emit()
	assert_false(m.session.current_hint.is_empty())
	var expected_text = m.hint_text(m.session.current_hint["text"])
	assert_eq(m.bubble.text, expected_text)
	assert_ne(m.bubble.text, m.session.current_hint["text"])
