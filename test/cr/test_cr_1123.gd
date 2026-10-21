extends GutTest

const LicensesPanel = preload("res://scenes/licenses_panel.gd")


func _make_lp() -> Control:
	var lp = LicensesPanel.new()
	add_child_autofree(lp)
	return lp


## CHECK: 1
func test_open_close_visibility_and_text() -> void:
	var lp = _make_lp()
	assert_false(lp.visible)

	lp.open("ABC", "en")
	assert_true(lp.visible)
	assert_eq(lp.body_label.text, "ABC")
	assert_eq(lp.close_button.text, "CLOSE")

	lp.open("ABC", "ja")
	assert_eq(lp.close_button.text, "閉じる")

	lp.close()
	assert_false(lp.visible)


## CHECK: 2
func test_place_offsets_children() -> void:
	var lp = _make_lp()
	assert_eq(lp.scroll.position, Vector2(60, 120))
	assert_eq(lp.scroll.size, Vector2(960, 1560))
	assert_eq(lp.close_button.position, Vector2(340, 1720))

	lp.place(Vector2(1180, 2120))
	assert_eq(lp.scroll.position, Vector2(110, 220))
	assert_eq(lp.close_button.position, Vector2(390, 1820))
	assert_eq(lp.dim.size, Vector2(1180, 2120))
