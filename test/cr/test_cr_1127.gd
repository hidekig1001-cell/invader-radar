extends GutTest

func test_cr_1127_sound_effects_line() -> void:
	## CHECK: 1
	var Lic = load("res://game/licenses.gd")
	var t = Lic.full_text()
	assert_true(t.contains("Sound effects: made with procedural synthesis (sine waves, noise and filters). No AI models or third-party assets."))
	assert_false(t.contains("Stable Audio"))
	assert_false(t.contains("Powered by Stability AI"))
	assert_true(t.contains("ACE-Step 1.5 (Apache License 2.0)"))
	assert_true(t.contains("FLUX.2 [klein] 4B (Apache License 2.0)"))
	assert_true(t.begins_with("ASSETS"))
