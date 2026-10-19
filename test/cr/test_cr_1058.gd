extends GutTest

const SplashScreen = preload("res://scenes/splash_screen.gd")

func _make_splash() -> Node:
	var s = SplashScreen.new()
	add_child_autofree(s)
	return s

## CHECK: 1
func test_timer_starts_on_ready() -> void:
	var s = _make_splash()
	assert_false(s.timer.is_stopped())
	assert_gt(s.timer.time_left, 0.0)

## CHECK: 2
func test_finished_emitted_after_timeout() -> void:
	var s = _make_splash()
	watch_signals(s)
	await get_tree().create_timer(2.5).timeout
	assert_signal_emit_count(s, "finished", 1)

## CHECK: 3
func test_finished_emitted_on_screen_touch() -> void:
	var s = _make_splash()
	watch_signals(s)
	var ev = InputEventScreenTouch.new()
	ev.pressed = true
	s.touch_area.gui_input.emit(ev)
	assert_signal_emit_count(s, "finished", 1)

## CHECK: 4
func test_finished_emitted_on_mouse_click() -> void:
	var s = _make_splash()
	watch_signals(s)
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	s.on_touch(ev)
	assert_signal_emit_count(s, "finished", 1)

## CHECK: 5
func test_finished_emitted_only_once_on_multiple_touches() -> void:
	var s = _make_splash()
	watch_signals(s)
	var ev1 = InputEventScreenTouch.new()
	ev1.pressed = true
	s.touch_area.gui_input.emit(ev1)
	var ev2 = InputEventScreenTouch.new()
	ev2.pressed = true
	s.touch_area.gui_input.emit(ev2)
	assert_signal_emit_count(s, "finished", 1)
