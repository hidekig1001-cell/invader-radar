# 画面の層（SPEC.md 3 節）: 上に 面・スコア・ヒントの残り・戻る・設定（仮）、下にヒントのボタン。
# 文字は英語（既定のフォントに日本語が無いため）。状態は変えない。押されたら signal を出すだけ。
extends Control

signal undo_pressed
signal hint_pressed
signal settings_pressed
signal apply_pressed
signal restart_pressed
signal title_requested
signal solve_pressed

const FONT_SIZE := 52
const SCREEN := Vector2(1080, 1920)
const ButtonStyle = preload("res://scenes/button_style.gd")

const ROW_BUTTON_RECTS := [Rect2(40, 260, 320, 100), Rect2(380, 260, 320, 100), Rect2(720, 260, 320, 100)]
const ROW_BUTTON_SIZE := Vector2(320, 100)

var level_label: Label
var score_label: Label
var hint_label: Label
var moves_label: Label
var time_label: Label
var undo_button: Button
var settings_button: Button
var hint_button: Button
var apply_button: Button
var restart_button: Button
var title_button: Button
var solve_button: Button

var language: String = "en"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = SCREEN
	level_label = _make_label(Rect2(40, 90, 320, 80), HORIZONTAL_ALIGNMENT_LEFT)
	score_label = _make_label(Rect2(380, 90, 320, 80), HORIZONTAL_ALIGNMENT_CENTER)
	hint_label = _make_label(Rect2(720, 90, 320, 80), HORIZONTAL_ALIGNMENT_RIGHT)
	moves_label = _make_label(Rect2(40, 170, 1000, 80), HORIZONTAL_ALIGNMENT_CENTER)
	undo_button = _make_button("UNDO", ROW_BUTTON_RECTS[0], undo_pressed)
	settings_button = _make_button("HOW TO PLAY", ROW_BUTTON_RECTS[2], settings_pressed)
	restart_button = _make_button("RESTART", ROW_BUTTON_RECTS[1], restart_pressed)
	hint_button = _make_button("HINT", Rect2(250, 1560, 380, 150), hint_pressed)
	apply_button = _make_button("APPLY", Rect2(640, 1560, 160, 150), apply_pressed)
	apply_button.add_theme_font_size_override("font_size", 40)
	apply_button.visible = false
	title_button = make_title_button()

	if OS.is_debug_build():
		solve_button = _make_button("ANSWER", Rect2(40, 1560, 200, 150), solve_pressed)
		solve_button.add_theme_font_size_override("font_size", 36)
	else:
		solve_button = null

	ButtonStyle.apply_to(undo_button)
	ButtonStyle.apply_to(settings_button)
	ButtonStyle.apply_to(hint_button)
	ButtonStyle.apply_to(apply_button)
	ButtonStyle.apply_to(restart_button)
	ButtonStyle.apply_to(title_button)
	if solve_button != null:
		ButtonStyle.apply_to(solve_button)

	finish_row_buttons([undo_button, restart_button, settings_button], 320)
	time_label = _make_label(Rect2(720, 170, 320, 80), HORIZONTAL_ALIGNMENT_RIGHT)
	set_time(0.0)


func set_language(lang: String) -> void:
	language = lang
	undo_button.text = localized("UNDO", "戻す")
	settings_button.text = localized("HOW TO PLAY", "遊び方")
	restart_button.text = localized("RESTART", "やり直す")
	apply_button.text = localized("APPLY", "決定")
	if solve_button != null:
		solve_button.text = localized("ANSWER", "答え")
	finish_row_buttons([undo_button, restart_button, settings_button], 320)


func localized(en_text: String, ja_text: String) -> String:
	if language == "ja":
		return ja_text
	return en_text


# session.snapshot() の内容を表示する。
func update_from(snap: Dictionary) -> void:
	level_label.text = localized("LEVEL %d", "レベル %d") % int(snap.get("level", 0))
	score_label.text = localized("SCORE %d", "スコア %d") % int(snap.get("score", 0))
	hint_label.text = localized("HINT x%d", "ヒント x%d") % int(snap.get("hints", 0))
	moves_label.text = localized("MOVES %d", "手数 %d") % int(snap.get("moves", 0))
	hint_button.text = localized("HINT (%d)", "ヒント (%d)") % int(snap.get("hints", 0))
	hint_button.disabled = int(snap.get("hints", 0)) <= 0 or snap.get("status", "") != "playing"
	undo_button.disabled = snap.get("status", "") != "playing"


func set_apply_visible(on: bool) -> void:
	apply_button.visible = on


func set_tutorial_mode(on: bool) -> void:
	hint_button.disabled = on
	undo_button.disabled = on


func _make_label(r: Rect2, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.position = r.position
	l.size = r.size
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", FONT_SIZE)
	add_child(l)
	return l


func _make_button(text: String, r: Rect2, sig: Signal) -> Button:
	var b := Button.new()
	b.text = text
	b.position = r.position
	b.size = r.size
	b.add_theme_font_size_override("font_size", FONT_SIZE)
	b.pressed.connect(func() -> void: sig.emit())
	add_child(b)
	return b


func make_title_button() -> Button:
	var b := Button.new()
	b.text = "タイトルに\n戻る"
	b.position = Vector2(810, 1560)
	b.size = Vector2(230, 150)
	b.add_theme_font_size_override("font_size", 36)
	b.pressed.connect(func() -> void: title_requested.emit())
	add_child(b)
	return b


func fit_row_font_size(buttons: Array, max_width: int) -> int:
	var best_n := 1
	for n in range(52, 0, -1):
		var fits := true
		for b in buttons:
			b.add_theme_font_size_override("font_size", n)
			if b.get_combined_minimum_size().x > max_width:
				fits = false
				break
		if fits:
			best_n = n
			break
	return best_n


func finish_row_buttons(buttons: Array, max_width: int) -> void:
	var n := fit_row_font_size(buttons, max_width)
	for b in buttons:
		b.add_theme_font_size_override("font_size", n)
		b.size = ROW_BUTTON_SIZE


func set_time(sec: float) -> void:
	time_label.text = localized("TIME %s", "時間 %s") % format_time(sec)


static func format_time(sec: float) -> String:
	var s := int(sec)
	return "%d:%02d" % [floori(sec / 60.0), s % 60]
