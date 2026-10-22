extends GutTest

## CHECK: 1
func test_full_text_contains_assets_and_engine_license() -> void:
	var Licenses = load("res://game/licenses.gd")
	var t = Licenses.full_text()
	assert_true(t.begins_with("ASSETS"))
	assert_false(t.contains("Powered by Stability AI"))
	assert_false(t.contains("Stable Audio"))
	assert_true(t.contains("Sound effects: made with procedural synthesis (sine waves, noise and filters). No AI models or third-party assets."))
	assert_true(t.contains("FLUX.2 [klein] 4B (Apache License 2.0)"))
	assert_true(t.contains("ACE-Step 1.5 (Apache License 2.0)"))
	assert_true(t.contains(Engine.get_license_text()))

## CHECK: 2
func test_godot_text_and_parts_text() -> void:
	var Licenses = load("res://game/licenses.gd")
	assert_true(Licenses.godot_text().begins_with("This game uses Godot Engine, available under the following license:"))
	var k = Engine.get_license_info().keys()[0]
	var p = Licenses.parts_text()
	assert_true(p.contains(k))
	assert_true(p.contains(str(Engine.get_license_info()[k])))
