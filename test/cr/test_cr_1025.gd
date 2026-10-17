extends GutTest

const TitleScreen = preload("res://scenes/title_screen.gd")
const AppScript = preload("res://scenes/app.gd")


func _make_title_screen():
	var ts = TitleScreen.new()
	add_child_autofree(ts)
	await wait_frames(1)
	return ts


func _make_app():
	var app = AppScript.new()
	add_child_autofree(app)
	await wait_frames(1)
	return app


## CHECK: 1
func test_title_screen_initial_state() -> void:
	var ts = await _make_title_screen()
	assert_eq(ts.title_text(), "INVADER RADAR")
	assert_eq(ts.language_labels(), ["English", "日本語"])
	assert_eq(ts.language(), "")
	assert_false(ts.start_buttons_visible())


## CHECK: 2
func test_select_language_en() -> void:
	var ts = await _make_title_screen()
	ts.select_language("en")
	assert_eq(ts.language(), "en")
	assert_true(ts.start_buttons_visible())
	assert_eq(ts.start_labels(), ["START WITH TUTORIAL", "START NOW"])


## CHECK: 3
func test_select_language_ja_then_en() -> void:
	var ts = await _make_title_screen()
	ts.select_language("ja")
	assert_eq(ts.language(), "ja")
	assert_true(ts.start_buttons_visible())
	assert_eq(ts.start_labels(), ["チュートリアルから始める", "すぐに始める"])
	ts.select_language("en")
	assert_eq(ts.start_labels(), ["START WITH TUTORIAL", "START NOW"])


## CHECK: 4
func test_press_start_emits_signal() -> void:
	var ts = await _make_title_screen()
	watch_signals(ts)
	ts.press_start(true)
	assert_signal_emitted_with_parameters(ts, "start_requested", [true])
	ts.press_start(false)
	assert_signal_emitted_with_parameters(ts, "start_requested", [false])


## CHECK: 5
func test_app_starts_with_title_screen_and_start_game_true() -> void:
	var app = await _make_app()
	assert_not_null(app.splash)
	app.on_splash_finished()
	await wait_frames(1)
	assert_not_null(app.title_screen)
	assert_null(app.main)
	app.start_game(true)
	await wait_frames(2)
	assert_not_null(app.main)
	assert_eq(app.main.start_with_tutorial, true)
	assert_null(app.title_screen)


## CHECK: 6
func test_app_start_game_false() -> void:
	var app = await _make_app()
	app.start_game(false)
	await wait_frames(2)
	assert_not_null(app.main)
	assert_eq(app.main.start_with_tutorial, false)
