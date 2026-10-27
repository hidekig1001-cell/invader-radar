extends Control

signal closed

const ButtonStyle = preload("res://scenes/button_style.gd")
const SoundSettings = preload("res://game/sound_settings.gd")

var dim: ColorRect
var body_label: Label
var close_button: Button
var settings_path: String = "user://settings.json"
var language: String = "en"
var sound_button: Button


func _ready() -> void:
	position = Vector2.ZERO
	size = Vector2(1080, 1920)
	mouse_filter = Control.MOUSE_FILTER_STOP

	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var box := StyleBoxFlat.new()
	box.bg_color = Color8(190, 228, 245)
	box.border_color = Color(1, 1, 1)
	box.set_border_width_all(4)
	box.set_corner_radius_all(24)
	box.content_margin_left = 40
	box.content_margin_right = 40

	body_label = Label.new()
	body_label.position = Vector2(90, 240)
	body_label.size = Vector2(900, 1100)
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_stylebox_override("normal", box)
	body_label.add_theme_font_size_override("font_size", 34)
	body_label.add_theme_color_override("font_color", Color8(30, 30, 40))
	add_child(body_label)

	close_button = Button.new()
	close_button.position = Vector2(340, 1360)
	close_button.size = Vector2(400, 130)
	ButtonStyle.apply_to(close_button)
	close_button.add_theme_font_size_override("font_size", 48)
	close_button.pressed.connect(close)
	add_child(close_button)

	sound_button = Button.new()
	sound_button.position = Vector2(340, 1520)
	sound_button.size = Vector2(400, 120)
	ButtonStyle.apply_to(sound_button)
	sound_button.add_theme_font_size_override("font_size", 44)
	sound_button.pressed.connect(toggle_sound)
	add_child(sound_button)

	visible = false


func open(lang: String) -> void:
	language = lang
	body_label.text = rules_text(lang)
	if lang == "ja":
		close_button.text = "閉じる"
	else:
		close_button.text = "CLOSE"
	update_sound_label()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func place(screen: Vector2) -> void:
	var offset := (screen - Vector2(1080, 1920)) / 2.0
	size = screen
	dim.size = screen
	body_label.position = Vector2(90, 240) + offset
	close_button.position = Vector2(340, 1360) + offset
	sound_button.position = Vector2(340, 1520) + offset


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
	var m = SoundSettings.load_muted(settings_path)
	if language == "ja":
		if m:
			return "音 ON"
		else:
			return "音 OFF"
	else:
		if m:
			return "SOUND ON"
		else:
			return "SOUND OFF"


static func rules_text(lang: String) -> String:
	if lang == "ja":
		return "ルール\n・各行・各列・各色に、\n　宇宙人を 1 人ずつ置く。\n・宇宙人どうしは、縦・横・斜めにも\n　隣り合ってはいけない。\n・数字は、まわりの 8 マスにいる\n　宇宙人の数。\n　数字のマスに宇宙人はいない。\n・? の岩には、宇宙人を置けない。\n\n操作\n・タップ: ×\n・ダブルタップ: 宇宙人\n・スワイプ: なぞったマスに ×\n\nボタン\n・ヒント: 次の 1 手を教える\n・戻す: 1 手戻す\n・やり直す: この面を最初から"
	else:
		return "RULES\n- One alien in each row, column and color.\n- Aliens must not touch, even diagonally.\n- A number tells how many aliens\n  are in the 8 cells around it.\n  No alien is on a number cell.\n- You cannot place an alien on a ? rock.\n\nCONTROLS\n- Tap: X\n- Double tap: alien\n- Swipe: X on the cells you swipe\n\nBUTTONS\n- Hint: shows the next move\n- Undo: takes back one move\n- Restart: starts this level over"
