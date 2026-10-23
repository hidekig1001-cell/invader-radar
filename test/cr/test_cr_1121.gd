extends GutTest

func test_sound_toggle_and_labels() -> void:
	## CHECK: 1
	var Save = load("res://game/session_save.gd")
	var Prefs = load("res://game/sound_settings.gd")
	var RulesPanel = load("res://scenes/rules_panel.gd")
	var path = "user://test_cr_1121_settings.json"
	Save.write_text(path, "")
	var rp = RulesPanel.new()
	rp.settings_path = path
	add_child_autofree(rp)
	rp.open("en")
	assert_eq(rp.sound_button.text, "SOUND OFF")
	rp.toggle_sound()
	assert_true(AudioServer.is_bus_mute(0))
	assert_true(Prefs.load_muted(path))
	assert_eq(rp.sound_button.text, "SOUND ON")
	rp.open("ja")
	assert_eq(rp.sound_button.text, "音 ON")
	rp.toggle_sound()
	assert_false(AudioServer.is_bus_mute(0))
	assert_false(Prefs.load_muted(path))
	assert_eq(rp.sound_button.text, "音 OFF")

func test_sound_button_geometry() -> void:
	## CHECK: 2
	var RulesPanel = load("res://scenes/rules_panel.gd")
	var rp = RulesPanel.new()
	rp.settings_path = "user://test_cr_1121_settings.json"
	add_child_autofree(rp)
	assert_eq(rp.sound_button.position, Vector2(340, 1520))
	assert_eq(rp.sound_button.size, Vector2(400, 120))
	rp.place(Vector2(1180, 2120))
	assert_eq(rp.sound_button.position, Vector2(390, 1620))
	assert_eq(rp.close_button.position, Vector2(390, 1460))
