extends GutTest

const Hud = preload("res://scenes/hud.gd")
const Save = preload("res://game/session_save.gd")


func _make_hud(path: String) -> Node:
	var h = Hud.new()
	add_child_autofree(h)
	h.settings_path = path
	return h


## CHECK: 1
func test_sound_button_toggle() -> void:
	var path = "user://test_cr_1131_settings.json"
	Save.write_text(path, "")
	var h = _make_hud(path)
	h.update_sound_label()

	assert_eq(h.sound_button.position, Vector2(380, 1614))
	assert_eq(h.sound_button.size, Vector2(320, 100))
	assert_eq(h.sound_button.text, "SOUND OFF")

	h.toggle_sound()
	assert_eq(h.sound_button.text, "SOUND ON")
	assert_true(AudioServer.is_bus_mute(0))
	assert_eq(Save.read_dict(path)["muted"], true)

	h.toggle_sound()
	assert_eq(h.sound_button.text, "SOUND OFF")
	assert_false(AudioServer.is_bus_mute(0))


## CHECK: 2
func test_sound_label_language_and_update_from() -> void:
	var path = "user://test_cr_1131_lang.json"
	Save.write_json(path, {"muted": true})
	var h = _make_hud(path)
	h.set_language("ja")
	assert_eq(h.sound_button.text, "音 ON")

	Save.write_json(path, {"muted": false})
	h.update_from({"level": 1, "score": 0, "hints": 3, "moves": 0, "status": "playing"})
	assert_eq(h.sound_button.text, "音 OFF")
