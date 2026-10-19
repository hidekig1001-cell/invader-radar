extends GutTest

const Session = preload("res://game/session.gd")
const Rules = preload("res://core/rules.gd")
const HUD = preload("res://scenes/hud.gd")
const MainScene = preload("res://scenes/main.tscn")


func test_solve_now_clears_board() -> void:
	## CHECK: 1
	var s = Session.new()
	assert_true(s.solve_now())
	assert_eq(s.status, "cleared")
	assert_true(Rules.is_solved(s.board, s.level))
	assert_eq(s.board.pieces().size(), s.level.width)


func test_solve_now_removes_marks() -> void:
	## CHECK: 2
	var s = Session.new()
	s.tap(1, 0)
	assert_true(s.solve_now())
	assert_eq(s.status, "cleared")
	assert_eq(s.board.marks().size(), 0)


func test_solve_now_twice_fails_second_time() -> void:
	## CHECK: 3
	var s = Session.new()
	s.solve_now()
	var score_after_first = s.score
	assert_false(s.solve_now())
	assert_eq(s.score, score_after_first)


func test_hud_has_solve_button_in_debug() -> void:
	## CHECK: 4
	var hud = HUD.new()
	add_child_autofree(hud)
	await wait_frames(1)
	assert_not_null(hud.solve_button)
	assert_true(hud.solve_button.visible)
	assert_eq(hud.solve_button.position, Vector2(40, 1560))
	assert_eq(hud.solve_button.size, Vector2(200, 150))
	assert_true(hud.has_signal("solve_pressed"))


func test_main_solve_pressed_clears_session() -> void:
	## CHECK: 5
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	m.hud.solve_pressed.emit()
	assert_eq(m.session.status, "cleared")
