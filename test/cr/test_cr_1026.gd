extends GutTest

const AppScript = preload("res://scenes/app.gd")
const MainScene = preload("res://scenes/main.tscn")
const HudScript = preload("res://scenes/hud.gd")


func test_chosen_language_default_and_ja() -> void:
	## CHECK: 1
	var app = AppScript.new()
	add_child_autofree(app)
	await wait_frames(2)
	assert_ne(app.splash, null)
	app.on_splash_finished()
	await wait_frames(1)
	assert_eq(app.chosen_language(), "en")
	app.title_screen._lang_btn_ja.pressed.emit()
	assert_eq(app.chosen_language(), "ja")


func test_start_game_passes_language_to_main() -> void:
	## CHECK: 2
	var app = AppScript.new()
	add_child_autofree(app)
	await wait_frames(2)
	assert_ne(app.splash, null)
	app.on_splash_finished()
	await wait_frames(1)
	app.title_screen._lang_btn_ja.pressed.emit()
	app.start_game(false)
	assert_eq(app.main.language, "ja")

	var app2 = AppScript.new()
	add_child_autofree(app2)
	await wait_frames(2)
	assert_ne(app2.splash, null)
	app2.on_splash_finished()
	await wait_frames(1)
	app2.start_game(false)
	assert_eq(app2.main.language, "en")


func test_main_passes_language_to_hud() -> void:
	## CHECK: 3
	var m = MainScene.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.hud.language, "ja")


func test_hud_set_language_ja_buttons() -> void:
	## CHECK: 4
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.set_language("ja")
	assert_eq(hud.undo_button.text, "戻す")
	assert_eq(hud.settings_button.text, "説明")
	assert_eq(hud.apply_button.text, "決定")


func test_hud_set_language_back_to_en() -> void:
	## CHECK: 5
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.set_language("ja")
	assert_eq(hud.undo_button.text, "戻す")
	hud.set_language("en")
	assert_eq(hud.undo_button.text, "UNDO")
	assert_eq(hud.settings_button.text, "RULES")
	assert_eq(hud.apply_button.text, "APPLY")


func test_hud_update_from_ja_labels() -> void:
	## CHECK: 6
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.set_language("ja")
	var snap = {"level": 1, "score": 0, "hints": 3, "moves": 0, "status": "playing"}
	hud.update_from(snap)
	assert_eq(hud.level_label.text, "1")
	assert_eq(hud.score_label.text, "0")
	assert_eq(hud.hint_label.text, "3")
	assert_eq(hud.moves_label.text, "0")
	assert_eq(hud.level_name_label.text, "レベル")
	assert_eq(hud.score_name_label.text, "スコア")
	assert_eq(hud.hint_name_label.text, "残りヒント")
	assert_eq(hud.moves_name_label.text, "手数")


func test_hud_update_from_ja_hint_button() -> void:
	## CHECK: 7
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.set_language("ja")
	var snap = {"level": 1, "score": 0, "hints": 3, "moves": 0, "status": "playing"}
	hud.update_from(snap)
	assert_eq(hud.hint_button.text, "ヒント (3)")


func test_main_help_text_ja() -> void:
	## CHECK: 8
	var m = MainScene.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.bubble.text, "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×")


func test_main_cleared_text_ja() -> void:
	## CHECK: 9
	var m = MainScene.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	const Solver = preload("res://core/solver.gd")
	var cells = Solver.solutions(m.session.level, 1)[0]
	for c in cells:
		m.session.double_tap(c.x, c.y)
	assert_eq(m.session.status, "cleared")
	m._refresh()
	assert_eq(m.bubble.text, "クリア！  タップで次の面")


func test_hud_localized() -> void:
	## CHECK: 10
	var hud = HudScript.new()
	add_child_autofree(hud)
	await wait_frames(2)
	assert_eq(hud.localized("HINT (%d)", "ヒント (%d)"), "HINT (%d)")
	hud.set_language("ja")
	assert_eq(hud.localized("HINT (%d)", "ヒント (%d)"), "ヒント (%d)")
