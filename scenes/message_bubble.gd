# 画面の層（SPEC.md 3 節）: 盤の上に出す吹き出し（短い言葉）。show_text で出し、時間が来たら消える。
extends Label

const BOX := Rect2(90, 340, 900, 120)
const FONT_SIZE := 44

var _time_left: float = 0.0


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


func _process(delta: float) -> void:
	if visible and _time_left > 0.0:
		_time_left -= delta
		if _time_left <= 0.0:
			clear_text()
