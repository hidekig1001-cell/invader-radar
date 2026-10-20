extends GutTest

const TitleScreen = preload("res://scenes/title_screen.gd")
const AppScript = preload("res://scenes/app.gd")


## CHECK: 1
func test_cr1099_1_title_screen_emits_quit_requested_on_back_request() -> void:
	var t = TitleScreen.new()
	add_child_autofree(t)
	await wait_frames(2)
	watch_signals(t)
	t.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	assert_signal_emitted(t, "quit_requested")


## CHECK: 2
func test_cr1099_2_app_connects_quit_requested_to_quit_app() -> void:
	var app = AppScript.new()
	add_child_autofree(app)
	await wait_frames(2)
	app.on_splash_finished()
	assert_true(app.title_screen.quit_requested.is_connected(app.quit_app))

	app.start_game(false)
	await wait_frames(2)
	app.show_title()
	assert_true(app.title_screen.quit_requested.is_connected(app.quit_app))
