extends GutTest

func test_load_save_muted() -> void:
	## CHECK: 1
	var Save = load("res://game/session_save.gd")
	var SoundSettings = load("res://game/sound_settings.gd")
	var path = "user://test_cr_1119_settings.json"
	
	Save.write_text(path, "")
	assert_eq(SoundSettings.load_muted(path), false)
	
	SoundSettings.save_muted(path, true)
	assert_eq(SoundSettings.load_muted(path), true)
	assert_eq(Save.read_dict(path)["muted"], true)
	
	Save.write_json(path, {"lang": "ja"})
	SoundSettings.save_muted(path, true)
	assert_eq(Save.read_dict(path)["lang"], "ja")
	assert_eq(Save.read_dict(path)["muted"], true)
	
	SoundSettings.save_muted(path, false)
	assert_eq(SoundSettings.load_muted(path), false)


func test_apply_mute() -> void:
	## CHECK: 2
	var SoundSettings = load("res://game/sound_settings.gd")
	
	SoundSettings.apply(true)
	assert_true(AudioServer.is_bus_mute(0))
	
	SoundSettings.apply(false)
	assert_false(AudioServer.is_bus_mute(0))
