extends RefCounted

const ASSETS_TEXT := "ASSETS\n- Images: generated with FLUX.2 [klein] 4B (Apache License 2.0). Backgrounds removed with BiRefNet (MIT License).\n- Music: generated with ACE-Step 1.5 (Apache License 2.0).\n- Sound effects: made with procedural synthesis (sine waves, noise and filters). No AI models or third-party assets."

static func godot_text() -> String:
	return "This game uses Godot Engine, available under the following license:\n\n" + Engine.get_license_text()

static func parts_text() -> String:
	var info = Engine.get_license_info()
	var result := ""
	for key in info.keys():
		result += str(key) + "\n\n" + str(info[key]) + "\n\n"
	return result

static func full_text() -> String:
	return ASSETS_TEXT + "\n\n" + godot_text() + "\n\n" + parts_text()
