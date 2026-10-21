extends GutTest

const TitleScreen = preload("res://scenes/title_screen.gd")
const LicText = preload("res://game/licenses.gd")

func _start_title_screen():
	var ts = TitleScreen.new()
	ts.settings_path = "user://test_cr_1124_settings.json"
	add_child_autofree(ts)
	await wait_frames(2)
	return ts

## CHECK: 1
func test_licenses_button_initial_state() -> void:
	var ts = await _start_title_screen()
	assert_eq(ts.licenses_btn.text, "LICENSES")
	assert_eq(ts.licenses_btn.size, Vector2(300, 90))
	assert_false(ts.licenses_panel.visible)

## CHECK: 1
func test_open_licenses_shows_panel() -> void:
	var ts = await _start_title_screen()
	ts.open_licenses()
	assert_true(ts.licenses_panel.visible)
	assert_eq(ts.licenses_panel.body_label.text, LicText.full_text())
	assert_eq(ts.licenses_panel.close_button.text, "CLOSE")

## CHECK: 1
func test_select_language_ja_updates_license_button_text() -> void:
	var ts = await _start_title_screen()
	ts.select_language("ja")
	assert_eq(ts.licenses_btn.text, "ライセンス")

## CHECK: 1
func test_open_licenses_after_ja_shows_close_ja() -> void:
	var ts = await _start_title_screen()
	ts.select_language("ja")
	ts.open_licenses()
	assert_eq(ts.licenses_panel.close_button.text, "閉じる")
