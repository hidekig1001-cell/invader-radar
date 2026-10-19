extends GutTest

const TitleScreen = preload("res://scenes/title_screen.gd")
const App = preload("res://scenes/app.gd")
const SessionSave = preload("res://game/session_save.gd")

func _make_title() -> TitleScreen:
	var t = TitleScreen.new()
	add_child_autofree(t)
	return t

## CHECK: 1
func test_fresh_start_button_en() -> void:
	var t = _make_title()
	assert_false(t._start_btn_fresh.visible)
	t.select_language("en")
	assert_true(t._start_btn_fresh.visible)
	assert_eq(t._start_btn_fresh.text, "START OVER")
	assert_eq(t._start_btn_fresh.position, Vector2(150, 1600))
	assert_eq(t._start_btn_fresh.size, Vector2(780, 160))

## CHECK: 2
func test_fresh_start_button_ja() -> void:
	var t = _make_title()
	assert_false(t._start_btn_fresh.visible)
	t.select_language("ja")
	assert_true(t._start_btn_fresh.visible)
	assert_eq(t._start_btn_fresh.text, "はじめから")
	assert_eq(t._start_btn_fresh.position, Vector2(150, 1600))
	assert_eq(t._start_btn_fresh.size, Vector2(780, 160))

## CHECK: 3
func test_press_fresh_start_emits_signal() -> void:
	var t = _make_title()
	watch_signals(t)
	t.press_fresh_start()
	assert_signal_emit_count(t, "fresh_start_requested", 1)
	assert_signal_emit_count(t, "start_requested", 0)

## CHECK: 4
func test_apply_screen_layout_fresh_button() -> void:
	var t = _make_title()
	t.apply_screen_layout(Vector2(1080, 2424))
	assert_eq(t._start_btn_fresh.position, Vector2(150, 1852))

## CHECK: 5
func test_start_fresh_game_clears_save_and_starts() -> void:
	var p = "user://test_cr1055_a.json"
	SessionSave.write_json(p, {"level_index": 2, "score": 150, "hints": 1})
	var app = App.new()
	add_child_autofree(app)
	app.save_path = p
	app.start_fresh_game()
	assert_eq(app.main.session.level_index, 0)
	assert_eq(app.main.session.score, 0)
	assert_eq(app.main.session.hints, 3)
	assert_eq(SessionSave.read_json(p), {})

## CHECK: 6
func test_app_connects_fresh_start_requested() -> void:
	var app = App.new()
	add_child_autofree(app)
	app.on_splash_finished()
	assert_true(app.title_screen.fresh_start_requested.is_connected(app.start_fresh_game))
	app.show_title()
	assert_true(app.title_screen.fresh_start_requested.is_connected(app.start_fresh_game))
