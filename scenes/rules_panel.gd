extends Control

signal closed

const ButtonStyle = preload("res://scenes/button_style.gd")

var dim: ColorRect
var body_label: Label
var close_button: Button


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
	body_label.position = Vector2(90, 420)
	body_label.size = Vector2(900, 900)
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_stylebox_override("normal", box)
	body_label.add_theme_font_size_override("font_size", 40)
	body_label.add_theme_color_override("font_color", Color8(30, 30, 40))
	add_child(body_label)

	close_button = Button.new()
	close_button.position = Vector2(340, 1360)
	close_button.size = Vector2(400, 130)
	ButtonStyle.apply_to(close_button)
	close_button.add_theme_font_size_override("font_size", 48)
	close_button.pressed.connect(close)
	add_child(close_button)

	visible = false


func open(lang: String) -> void:
	body_label.text = rules_text(lang)
	if lang == "ja":
		close_button.text = "閉じる"
	else:
		close_button.text = "CLOSE"
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func place(screen: Vector2) -> void:
	var offset := (screen - Vector2(1080, 1920)) / 2.0
	size = screen
	dim.size = screen
	body_label.position = Vector2(90, 420) + offset
	close_button.position = Vector2(340, 1360) + offset


static func rules_text(lang: String) -> String:
	if lang == "ja":
		return "ルール\n・各行・各列・各色に、駒を 1 つずつ置く。\n・駒どうしは、縦・横・斜めにも隣り合ってはいけない。\n\n操作\n・タップ: ×\n・ダブルタップ: 駒\n・スワイプ: なぞったマスに ×\n\nボタン\n・ヒント: 次の 1 手を教える\n・戻す: 1 手戻す\n・やり直す: この面を最初から"
	else:
		return "RULES\n- One piece in each row, column and color.\n- Pieces must not touch, even diagonally.\n\nCONTROLS\n- Tap: X\n- Double tap: piece\n- Swipe: X on the cells you swipe\n\nBUTTONS\n- Hint: shows the next move\n- Undo: takes back one move\n- Restart: starts this level over"
