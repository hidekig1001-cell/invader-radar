extends GutTest

const AppScene = preload("res://scenes/app.tscn")
const SplashScreenScript = preload("res://scenes/splash_screen.gd")


func _start_app():
	var app = AppScene.instantiate()
	add_child_autofree(app)
	await wait_frames(2)
	return app


func _make_splash():
	var splash = SplashScreenScript.new()
	add_child_autofree(splash)
	await wait_frames(1)
	return splash


## CHECK: 1
func test_app_starts_with_splash() -> void:
	var app = await _start_app()
	assert_not_null(app.splash)
	assert_eq(app.get_child(0), app.splash)
	assert_not_null(app.splash.timer)
	assert_eq(app.splash.timer.wait_time, 2.0)
	assert_true(app.splash.background is ColorRect)
	assert_not_null(app.splash.logo)


## CHECK: 2
func test_splash_has_background_and_logo() -> void:
	var splash = await _make_splash()
	assert_true(splash.background is ColorRect)
	assert_eq(splash.logo.texture.resource_path, "res://assets/autedev_logo.png")


## CHECK: 3
func test_apply_screen_layout_center_1080x2424() -> void:
	var splash = await _make_splash()
	splash.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(splash.background.size, Vector2(1080, 2424))
	assert_true(splash.logo.get_global_rect().get_center().is_equal_approx(Vector2(540, 1212)))


## CHECK: 4
func test_apply_screen_layout_center_1080x1920() -> void:
	var splash = await _make_splash()
	splash.apply_screen_layout(Vector2(1080, 1920))
	assert_true(splash.logo.get_global_rect().get_center().is_equal_approx(Vector2(540, 960)))
	assert_eq(splash.logo.scale, Vector2(1, 1))


## CHECK: 5
func test_apply_screen_layout_scale_512x1024() -> void:
	var splash = await _make_splash()
	splash.apply_screen_layout(Vector2(512, 1024))
	assert_eq(splash.logo.scale, Vector2(0.5, 0.5))


## CHECK: 6
func test_timer_one_shot() -> void:
	var splash = await _make_splash()
	assert_true(splash.timer.one_shot)


## CHECK: 7
func test_finish_emits_finished_once() -> void:
	var splash = await _make_splash()
	watch_signals(splash)
	splash.timer.timeout.emit()
	assert_signal_emit_count(splash, "finished", 1)
	assert_true(splash.finished_sent)
	splash.finish()
	assert_signal_emit_count(splash, "finished", 1)


## CHECK: 8
func test_touch_finishes_once() -> void:
	var splash = await _make_splash()
	watch_signals(splash)
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 1212)
	splash.on_touch(down)
	assert_signal_emit_count(splash, "finished", 1)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = Vector2(540, 1212)
	splash.on_touch(up)
	assert_signal_emit_count(splash, "finished", 1)


## CHECK: 9
func test_splash_finished_creates_title_screen() -> void:
	var app = await _start_app()
	app.splash.finished.emit()
	await wait_frames(1)
	assert_null(app.splash)
	assert_not_null(app.title_screen)
	app.title_screen.start_requested.emit(true)
	await wait_frames(1)
	assert_not_null(app.main)


## CHECK: 10
func test_start_game_during_splash_removes_splash() -> void:
	var app = await _start_app()
	assert_not_null(app.splash)
	app.start_game(true)
	await wait_frames(1)
	assert_null(app.splash)
	assert_not_null(app.main)
	app.on_splash_finished()
	await wait_frames(1)
	assert_null(app.title_screen)
