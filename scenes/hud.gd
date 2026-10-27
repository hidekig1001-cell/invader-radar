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
const SoundSettings = preload("res://game/sound_settings.gd")

const ROW_BUTTON_RECTS := [Rect2(40, 1506, 320, 100), Rect2(380, 1506, 320, 100), Rect2(720, 1506, 320, 100)]
const ROW_BUTTON_SIZE := Vector2(320, 100)

const TABLE_RECT := Rect2(40, 90, 1000, 160)
const TABLE_BG := Color8(60, 45, 120)
const TABLE_LINE := Color8(140, 120, 210)
const TABLE_TEXT := Color8(245, 240, 255)
const TABLE_FONT_SIZE := 40

var level_label: Label
var score_label: Label
var hint_label: Label
var moves_label: Label
var time_label: Label
var aliens_name_label: Label
var aliens_label: Label
var undo_button: Button
var settings_button: Button
var hint_button: Button
var apply_button: Button
var restart_button: Button
var title_button: Button
var solve_button: Button

var level_name_label: Label
var score_name_label: Label
var hint_name_label: Label
var moves_name_label: Label
var time_name_label: Label

var language: String = "en"
var tutorial_mode: bool = false
var settings_path: String = "user://settings.json"
var sound_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = SCREEN
	
	# Table Labels Setup
	level_name_label = make_table_label(table_cell_rect(0, 0), HORIZONTAL_ALIGNMENT_LEFT)
	level_label = make_table_label(table_cell_rect(0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	
	score_name_label = make_table_label(table_cell_rect(1, 0), HORIZONTAL_ALIGNMENT_LEFT)
	score_label = make_table_label(table_cell_rect(1, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	
	hint_name_label = make_table_label(table_cell_rect(2, 0), HORIZONTAL_ALIGNMENT_LEFT)
	hint_label = make_table_label(table_cell_rect(2, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	
	moves_name_label = make_table_label(table_cell_rect(1, 1), HORIZONTAL_ALIGNMENT_LEFT)
	moves_label = make_table_label(table_cell_rect(1, 1), HORIZONTAL_ALIGNMENT_RIGHT)
	
	time_name_label = make_table_label(table_cell_rect(2, 1), HORIZONTAL_ALIGNMENT_LEFT)
	time_label = make_table_label(table_cell_rect(2, 1), HORIZONTAL_ALIGNMENT_RIGHT)
	
	aliens_name_label = make_table_label(table_cell_rect(0, 1), HORIZONTAL_ALIGNMENT_LEFT)
	aliens_label = make_table_label(table_cell_rect(0, 1), HORIZONTAL_ALIGNMENT_RIGHT)
	
	set_table_names()

	undo_button = _make_button("UNDO", ROW_BUTTON_RECTS[0], undo_pressed)
	settings_button = _make_button("RULES", ROW_BUTTON_RECTS[2], settings_pressed)
	restart_button = _make_button("RESTART", ROW_BUTTON_RECTS[1], restart_pressed)
	hint_button = _make_button("HINT", Rect2(40, 1614, 320, 100), hint_pressed)
	apply_button = _make_button("APPLY", Rect2(40, 1614, 320, 100), apply_pressed)
	apply_button.add_theme_font_size_override("font_size", 40)
	apply_button.visible = false
	title_button = make_title_button()

	if OS.is_debug_build():
		solve_button = _make_button("ANSWER", Rect2(40, 1866, 200, 50), solve_pressed)
		solve_button.add_theme_font_size_override("font_size", 28)
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
	set_time(0.0)

	sound_button = Button.new()
	sound_button.position = Vector2(380, 1614)
	sound_button.size = Vector2(320, 100)
	ButtonStyle.apply_to(sound_button)
	sound_button.add_theme_font_size_override("font_size", 40)
	sound_button.pressed.connect(toggle_sound)
	add_child(sound_button)
	update_sound_label()


func set_language(lang: String) -> void:
	language = lang
	undo_button.text = localized("UNDO", "戻す")
	settings_button.text = localized("RULES", "説明")
	restart_button.text = localized("RESTART", "やり直す")
	apply_button.text = localized("APPLY", "決定")
	title_button.text = localized("BACK TO TITLE", "タイトルに戻る")
	if solve_button != null:
		solve_button.text = localized("ANSWER", "答え")
	finish_row_buttons([undo_button, restart_button, settings_button], 320)
	set_table_names()
	update_sound_label()


func localized(en_text: String, ja_text: String) -> String:
	if language == "ja":
		return ja_text
	return en_text


# session.snapshot() の内容を表示する。
func update_from(snap: Dictionary) -> void:
	level_label.text = str(int(snap.get("level", 0)))
	score_label.text = str(int(snap.get("score", 0)))
	hint_label.text = str(int(snap.get("hints", 0)))
	moves_label.text = str(int(snap.get("moves", 0)))
	aliens_label.text = str(aliens_left(snap))
	hint_button.text = localized("HINT (%d)", "ヒント (%d)") % int(snap.get("hints", 0))
	hint_button.disabled = tutorial_mode or int(snap.get("hints", 0)) <= 0 or snap.get("status", "") != "playing"
	undo_button.disabled = tutorial_mode or snap.get("status", "") != "playing"
	update_sound_label()


func set_apply_visible(on: bool) -> void:
	apply_button.visible = on


func set_tutorial_mode(on: bool) -> void:
	tutorial_mode = on


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
	b.text = "タイトルに戻る"
	b.position = Vector2(720, 1614)
	b.size = Vector2(320, 100)
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
	time_label.text = format_time(sec)


static func format_time(sec: float) -> String:
	var s := int(sec)
	return "%d:%02d" % [floori(sec / 60.0), s % 60]


static func table_cell_rect(col: int, row: int) -> Rect2:
	var cell_w := TABLE_RECT.size.x / 3.0
	var cell_h := TABLE_RECT.size.y / 2.0
	return Rect2(
		TABLE_RECT.position.x + col * cell_w,
		TABLE_RECT.position.y + row * cell_h,
		cell_w,
		cell_h
	)


func make_table_label(r: Rect2, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.position = r.position + Vector2(16, 0)
	l.size = r.size - Vector2(32, 0)
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", TABLE_FONT_SIZE)
	l.add_theme_color_override("font_color", TABLE_TEXT)
	add_child(l)
	return l


func set_table_names() -> void:
	level_name_label.text = localized("LEVEL", "レベル")
	score_name_label.text = localized("SCORE", "スコア")
	hint_name_label.text = localized("HINTS LEFT", "残りヒント")
	moves_name_label.text = localized("MOVES", "手数")
	time_name_label.text = localized("TIME", "経過時間")
	aliens_name_label.text = localized("ALIENS LEFT", "残り宇宙人")


func table_box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = TABLE_BG
	sb.border_color = TABLE_LINE
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(24)
	sb.anti_aliasing = true
	return sb


func _draw() -> void:
	draw_style_box(table_box(), TABLE_RECT)
	var cell_w := TABLE_RECT.size.x / 3.0
	var cell_h := TABLE_RECT.size.y / 2.0
	
	# Draw inner vertical lines
	for i in range(1, 3):
		var x := TABLE_RECT.position.x + i * cell_w
		draw_line(Vector2(x, TABLE_RECT.position.y), Vector2(x, TABLE_RECT.position.y + TABLE_RECT.size.y), TABLE_LINE, 3.0)
		
	# Draw inner horizontal line
	var y := TABLE_RECT.position.y + cell_h
	draw_line(Vector2(TABLE_RECT.position.x, y), Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x, y), TABLE_LINE, 3.0)


func toggle_sound() -> void:
	var m = not SoundSettings.load_muted(settings_path)
	SoundSettings.save_muted(settings_path, m)
	SoundSettings.apply(m)
	update_sound_label()


func update_sound_label() -> void:
	if sound_button != null:
		sound_button.text = sound_label()


# 押したときにどうなるかを出す（鳴っているとき OFF、消音のとき ON）。
func sound_label() -> String:
	var muted = SoundSettings.load_muted(settings_path)
	if muted:
		if language == "ja":
			return "音 ON"
		else:
			return "SOUND ON"
	else:
		if language == "ja":
			return "音 OFF"
		else:
			return "SOUND OFF"


static func aliens_left(snap: Dictionary) -> int:
	var board = snap.get("board", null)
	if board == null:
		return 0
	var width = int(board.get("width", 0))
	var pieces = int(board.get("pieces", 0))
	var left = width - pieces
	if left < 0:
		return 0
	return left
