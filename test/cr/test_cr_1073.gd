extends GutTest

const ClearEffectScript = preload("res://scenes/clear_effect.gd")
const MainScene = preload("res://scenes/main.tscn")


func test_clear_effect_play_and_process() -> void:
	## CHECK: 1
	var fx = ClearEffectScript.new()
	add_child_autofree(fx)
	
	fx.play(Vector2(540, 960))
	assert_true(fx.active)
	assert_eq(fx.particles.size(), 40)
	for p in fx.particles:
		assert_eq(p["pos"], Vector2(540, 960))
	
	fx._process(0.5)
	assert_true(fx.active)
	assert_ne(fx.particles[0]["pos"], Vector2(540, 960))
	
	fx._process(2.0)
	assert_false(fx.active)
	assert_eq(fx.particles.size(), 0)


func test_main_clear_effect_integration() -> void:
	## CHECK: 2
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	
	assert_not_null(m.clear_effect)
	assert_false(m.clear_effect.active)
	
	m.session.solve_now()
	assert_true(m.clear_effect.active)
	
	m.clear_effect.active = false
	m._refresh()
	assert_false(m.clear_effect.active)
