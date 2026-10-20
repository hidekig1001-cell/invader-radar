extends GutTest

const Session = preload("res://game/session.gd")
const Hud = preload("res://scenes/hud.gd")
const MainScene = preload("res://scenes/main.tscn")


## CHECK: 1
func test_session_elapsed_timer() -> void:
	var s = Session.new()
	assert_eq(s.elapsed, 0.0)
	s.tick(1.5)
	s.tick(2.0)
	assert_eq(s.elapsed, 3.5)
	s.solve_now()
	assert_eq(s.status, "cleared")
	s.tick(5.0)
	assert_eq(s.elapsed, 3.5)
	s.next_level()
	assert_eq(s.elapsed, 0.0)
	s.tick(4.0)
	s.restart_level()
	assert_eq(s.elapsed, 0.0)


## CHECK: 2
func test_hud_format_time() -> void:
	assert_eq(Hud.format_time(0.0), "0:00")
	assert_eq(Hud.format_time(59.9), "0:59")
	assert_eq(Hud.format_time(61.0), "1:01")
	assert_eq(Hud.format_time(754.0), "12:34")


## CHECK: 3
func test_main_process_updates_timer() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	assert_not_null(m.hud.time_label)
	m.session.elapsed = 0.0
	m._process(65.0)
	assert_eq(m.session.elapsed, 65.0)
	assert_eq(m.hud.time_label.text, "1:05")
	m.session.solve_now()
	m._process(10.0)
	assert_eq(m.session.elapsed, 65.0)
	assert_eq(m.hud.time_label.text, "1:05")
