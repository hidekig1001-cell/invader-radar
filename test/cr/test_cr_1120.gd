extends GutTest

const Save = preload("res://game/session_save.gd")
const Prefs = preload("res://game/sound_settings.gd")
const TitleScreen = preload("res://scenes/title_screen.gd")

func _make_title_screen(path: String) -> Node:
	var ts = TitleScreen.new()
	ts.settings_path = path
	add_child_autofree(ts)
	return ts

## CHECK: 1
func test_cr_1120_toggle_sound_and_label() -> void:
	var path = "user://test_cr_1120_settings.json"
	Save.write_text(path, "")
	var ts = _make_title_screen(path)
	
	assert_eq(ts.muted, false)
	assert_eq(ts.sound_label(), "SOUND ON")
	
	ts.toggle_sound()
	assert_eq(ts.muted, true)
	assert_true(AudioServer.is_bus_mute(0))
	assert_eq(Prefs.load_muted(path), true)
	assert_eq(ts.sound_label(), "SOUND OFF")
	
	ts.select_language("ja")
	assert_eq(ts.sound_label(), "音 OFF")
	
	ts.toggle_sound()
	assert_eq(ts.muted, false)
	assert_false(AudioServer.is_bus_mute(0))
	assert_eq(ts.sound_label(), "音 ON")

## CHECK: 2
func test_cr_1120_load_muted_from_file() -> void:
	var path = "user://test_cr_1120_settings.json"
	Save.write_json(path, {"muted": true})
	var ts = _make_title_screen(path)
	
	assert_eq(ts.muted, true)
	assert_true(AudioServer.is_bus_mute(0))
	
	ts.toggle_sound()
	assert_eq(ts.muted, false)
	assert_false(AudioServer.is_bus_mute(0))
