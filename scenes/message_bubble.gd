# 画面の層（SPEC.md 3 節）: 盤の上に出す吹き出し（短い言葉）。show_text で出し、時間が来たら消える。
extends Label

const BOX := Rect2(90, 340, 900, 120)
const FONT_SIZE := 44
const ButtonStyle = preload("res://scenes/button_style.gd")
const TILE_SIZE := Vector2(900, 160)
const TILE_OFFSET_Y := 200.0
const TILE_FONT_COLOR := Color8(74, 50, 10)
const PANEL_BOX := Rect2(90, 366, 900, 108)
const PANEL_FONT_SIZE := 30

var _time_left: float = 0.0
var tile_mode: bool = false
var panel_mode: bool = false
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
	box.bg_color = Color(1, 1, 1, 0.14)
	box.set_corner_radius_all(36)
	add_theme_stylebox_override("normal", box)
	normal_box = box
	visible = false


# seconds が 0 以下なら出しっぱなし（clear_text で消す）。
func show_text(text_to_show: String, seconds: float = 3.0) -> void:
	text = text_to_show
	_time_left = seconds
	visible = true


func clear_text() -> void:
	text = ""
	_time_left = 0.0
	visible = false
	if panel_mode:
		panel_mode = false
		position = normal_position
		size = BOX.size
		add_theme_stylebox_override("normal", normal_box)
		remove_theme_color_override("font_color")
		add_theme_font_size_override("font_size", FONT_SIZE)
	if tile_mode:
		tile_mode = false
		position = normal_position
		size = BOX.size
		add_theme_stylebox_override("normal", normal_box)
		remove_theme_color_override("font_color")


func show_tile(text_to_show: String, center: Vector2) -> void:
	if not tile_mode:
		normal_position = position
		tile_mode = true
	text = text_to_show
	_time_left = 0.0
	size = TILE_SIZE
	position = Vector2(center.x - TILE_SIZE.x / 2.0, center.y + TILE_OFFSET_Y - TILE_SIZE.y / 2.0)
	add_theme_stylebox_override("normal", ButtonStyle.make_box("res://assets/buttons/button_normal.png", 0))
	add_theme_color_override("font_color", TILE_FONT_COLOR)
	visible = true


func show_panel(text_to_show: String) -> void:
	if not panel_mode and not tile_mode:
		normal_position = position
	panel_mode = true
	text = text_to_show
	_time_left = 0.0
	add_theme_stylebox_override("normal", ButtonStyle.make_box("res://assets/buttons/button_normal.png", 0))
	add_theme_color_override("font_color", TILE_FONT_COLOR)
	add_theme_font_size_override("font_size", PANEL_FONT_SIZE)
	size = PANEL_BOX.size
	position = normal_position + (PANEL_BOX.position - BOX.position)
	visible = true


func _process(delta: float) -> void:
	if visible and _time_left > 0.0:
		_time_left -= delta
		if _time_left <= 0.0:
			clear_text()
