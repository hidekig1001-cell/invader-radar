# 画面の層（SPEC.md 3 節）: 上に 面・スコア・ヒントの残り・戻る・設定（仮）、下にヒントのボタン。
# 文字は英語（既定のフォントに日本語が無いため）。状態は変えない。押されたら signal を出すだけ。
extends Control

signal undo_pressed
signal hint_pressed
signal settings_pressed
signal apply_pressed
signal restart_pressed
signal title_requested

const FONT_SIZE := 52
const SCREEN := Vector2(1080, 1920)

var level_label: Label
var score_label: Label
var hint_label: Label
var moves_label: Label
var undo_button: Button
var settings_button: Button
var hint_button: Button
var apply_button: Button
var restart_button: Button
var title_button: Button

var language: String = "en"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = SCREEN
	level_label = _make_label(Rect2(40, 90, 320, 80), HORIZONTAL_ALIGNMENT_LEFT)
	score_label = _make_label(Rect2(380, 90, 320, 80), HORIZONTAL_ALIGNMENT_CENTER)
	hint_label = _make_label(Rect2(720, 90, 320, 80), HORIZONTAL_ALIGNMENT_RIGHT)
	moves_label = _make_label(Rect2(40, 170, 1000, 80), HORIZONTAL_ALIGNMENT_CENTER)
	undo_button = _make_button("UNDO", Rect2(40, 200, 300, 110), undo_pressed)
	settings_button = _make_button("HOW TO PLAY", Rect2(640, 200, 400, 110), settings_pressed)
	restart_button = _make_button("RESTART", Rect2(340, 250, 300, 80), restart_pressed)
	hint_button = _make_button("HINT", Rect2(250, 1560, 380, 150), hint_pressed)
	apply_button = _make_button("APPLY", Rect2(640, 1560, 160, 150), apply_pressed)
	apply_button.add_theme_font_size_override("font_size", 40)
	apply_button.visible = false
	title_button = make_title_button()


func set_language(lang: String) -> void:
	language = lang
	undo_button.text = localized("UNDO", "戻す")
	settings_button.text = localized("HOW TO PLAY", "遊び方")
	restart_button.text = localized("RESTART", "やり直す")
	apply_button.text = localized("APPLY", "決定")


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
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.25, 0.45, 0.85)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	b.add_theme_stylebox_override("normal", sb)
	b.pressed.connect(func() -> void: title_requested.emit())
	add_child(b)
	return b
