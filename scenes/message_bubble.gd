# 画面の層（SPEC.md 3 節）: 盤の上に出す吹き出し（短い言葉）。show_text で出し、時間が来たら消える。
extends Label

# 上は hud の UNDO・RESTART のボタンの下の端（y 360）から 8 あけ、下は盤の背景の上の端（y 466）の手前まで。
# 右の端は音のボタン（x 720 から）にかからない 660 幅（CR-1135）。
const BOX := Rect2(40, 368, 660, 96)
const FONT_SIZE := 36
const ButtonStyle = preload("res://scenes/button_style.gd")
const TILE_SIZE := Vector2(900, 160)
const TILE_OFFSET_Y := 200.0
const TILE_FONT_COLOR := Color8(74, 50, 10)
const PANEL_BOX := Rect2(40, 368, 660, 96)
const PANEL_FONT_SIZE := 28
const TEXT_MAX_FONT_SIZE := 52
const TEXT_MIN_FONT_SIZE := 24
const PANEL_MAX_FONT_SIZE := 48
const PANEL_MIN_FONT_SIZE := 20

var _time_left: float = 0.0
var tile_mode: bool = false
var panel_mode: bool = false
var blink_time: float = 0.0
var normal_position: Vector2 = Vector2.ZERO
var normal_box: StyleBox = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = BOX.position
	size = BOX.size
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_theme_font_size_override("font_size", FONT_SIZE)
	var box := StyleBoxFlat.new()
	box.bg_color = Color8(255, 200, 150)
	box.border_color = Color8(235, 150, 80)
	box.set_border_width_all(4)
	box.set_corner_radius_all(24)
	box.anti_aliasing = true
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	add_theme_stylebox_override("normal", box)
	normal_box = box
	set_normal_font_look()
	visible = false


# seconds が 0 以下なら出しっぱなし（clear_text で消す）。
func show_text(text_to_show: String, seconds: float = 3.0) -> void:
	text = text_to_show
	_time_left = seconds
	add_theme_font_size_override("font_size", fit_font_size(text_to_show, BOX.size, TEXT_MAX_FONT_SIZE, TEXT_MIN_FONT_SIZE))
	visible = true


# 字が box（枠の stylebox の上下左右の content margin を除いた中）に収まる一番大きい字の大きさ。
# max_size から 2 ずつ下げて探し、収まらなければ min_size。
func fit_font_size(t: String, box: Vector2, max_size: int, min_size: int) -> int:
	var sb := get_theme_stylebox("normal")
	var pad := Vector2.ZERO
	if sb != null:
		pad.x = sb.get_content_margin(SIDE_LEFT) + sb.get_content_margin(SIDE_RIGHT)
		pad.y = sb.get_content_margin(SIDE_TOP) + sb.get_content_margin(SIDE_BOTTOM)
	var fs := max_size
	while fs >= min_size:
		if text_height(t, box.x - pad.x, fs) <= box.y - pad.y:
			return fs
		fs -= 2
	return min_size


# Label（AUTOWRAP_WORD_SMART）が描くときの字の高さ。
# Font.get_multiline_string_size は日本語の行（端末の別のフォントで出る）を Label より低く測るので、
# Label と同じく行ごとに「字の形の高さ」と「フォントの高さ」の大きい方を取り、行と行の間に line_spacing を足す。
func text_height(t: String, width: float, fs: int) -> float:
	var font := get_theme_font("font")
	var para := TextParagraph.new()
	para.add_string(t, font, fs)
	para.width = width
	para.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	var n := para.get_line_count()
	var h := 0.0
	for li in range(n):
		h += maxf(para.get_line_size(li).y, font.get_height(fs))
	h += float(maxi(0, n - 1) * get_theme_constant("line_spacing"))
	return h


func clear_text() -> void:
	text = ""
	_time_left = 0.0
	visible = false
	if panel_mode:
		panel_mode = false
		blink_time = 0.0
		modulate.a = 1.0
		position = normal_position
		size = BOX.size
		add_theme_stylebox_override("normal", normal_box)
		set_normal_font_look()
		add_theme_font_size_override("font_size", FONT_SIZE)
	if tile_mode:
		tile_mode = false
		position = normal_position
		size = BOX.size
		add_theme_stylebox_override("normal", normal_box)
		set_normal_font_look()


func show_tile(text_to_show: String, center: Vector2) -> void:
	if not tile_mode:
		normal_position = position
		tile_mode = true
	text = text_to_show
	_time_left = 0.0
	size = TILE_SIZE
	position = Vector2(center.x - TILE_SIZE.x / 2.0, center.y + TILE_OFFSET_Y - TILE_SIZE.y / 2.0)
	add_theme_stylebox_override("normal", clear_tile_box())
	add_theme_color_override("font_color", TILE_FONT_COLOR)
	add_theme_constant_override("outline_size", 0)
	visible = true


func show_panel(text_to_show: String) -> void:
	if not panel_mode and not tile_mode:
		normal_position = position
		blink_time = 0.0
	panel_mode = true
	text = text_to_show
	_time_left = 0.0
	add_theme_stylebox_override("normal", ButtonStyle.make_box("res://assets/buttons/button_normal.png", 0))
	add_theme_color_override("font_color", TILE_FONT_COLOR)
	add_theme_constant_override("outline_size", 0)
	add_theme_font_size_override("font_size", fit_font_size(text_to_show, PANEL_BOX.size, PANEL_MAX_FONT_SIZE, PANEL_MIN_FONT_SIZE))
	size = PANEL_BOX.size
	position = normal_position + (PANEL_BOX.position - BOX.position)
	visible = true


# 吹き出しの字（淡いオレンジの地に濃い茶色の字、縁取りなし）。
func set_normal_font_look() -> void:
	add_theme_color_override("font_color", TILE_FONT_COLOR)
	add_theme_color_override("font_outline_color", Color8(150, 60, 0))
	add_theme_constant_override("outline_size", 0)


static func panel_alpha(t: float) -> float:
	return 0.55 + 0.45 * (0.5 + 0.5 * cos(TAU * t / 1.6))


func step_blink(delta: float) -> void:
	if panel_mode:
		blink_time += delta
		modulate.a = panel_alpha(blink_time)
	else:
		modulate.a = 1.0


func _process(delta: float) -> void:
	step_blink(delta)
	if visible and _time_left > 0.0:
		_time_left -= delta
		if _time_left <= 0.0:
			clear_text()


func clear_tile_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color8(255, 205, 222)
	box.border_color = Color8(232, 150, 180)
	box.set_border_width_all(4)
	box.set_corner_radius_all(24)
	box.anti_aliasing = true
	return box
