# 画面の層（SPEC.md 3 節）: 上に 面・スコア・ヒントの残り・戻る・設定（仮）、下にヒントのボタン。
# 文字は英語（既定のフォントに日本語が無いため）。状態は変えない。押されたら signal を出すだけ。
extends Control

signal undo_pressed
signal hint_pressed
signal settings_pressed
signal apply_pressed

const FONT_SIZE := 52
const SCREEN := Vector2(1080, 1920)

var level_label: Label
var score_label: Label
var hint_label: Label
var undo_button: Button
var settings_button: Button
var hint_button: Button
var apply_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = SCREEN
	level_label = _make_label(Rect2(40, 90, 320, 80), HORIZONTAL_ALIGNMENT_LEFT)
	score_label = _make_label(Rect2(380, 90, 320, 80), HORIZONTAL_ALIGNMENT_CENTER)
	hint_label = _make_label(Rect2(720, 90, 320, 80), HORIZONTAL_ALIGNMENT_RIGHT)
	undo_button = _make_button("UNDO", Rect2(40, 200, 300, 110), undo_pressed)
	settings_button = _make_button("SETTINGS", Rect2(740, 200, 300, 110), settings_pressed)
	hint_button = _make_button("HINT", Rect2(240, 1560, 600, 150), hint_pressed)
	apply_button = _make_button("APPLY", Rect2(850, 1560, 200, 150), apply_pressed)
	apply_button.visible = false


# session.snapshot() の内容を表示する。
func update_from(snap: Dictionary) -> void:
	level_label.text = "LEVEL %d" % int(snap.get("level", 0))
	score_label.text = "SCORE %d" % int(snap.get("score", 0))
	hint_label.text = "HINT x%d" % int(snap.get("hints", 0))
	hint_button.text = "HINT (%d)" % int(snap.get("hints", 0))
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
