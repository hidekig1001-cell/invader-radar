extends GutTest

func test_cr_1175_clear_effect_duration() -> void:
	## CHECK: 1
	var CE = load("res://scenes/clear_effect.gd")
	var fx = CE.new()
	add_child_autofree(fx)
	fx.play(Vector2(540, 960))
	fx._process(2.0)
	assert_true(fx.active)
	assert_eq(fx.particles.size(), 40)
	fx._process(0.5)
	assert_false(fx.active)
	assert_eq(fx.particles.size(), 0)
