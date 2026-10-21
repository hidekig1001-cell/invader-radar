extends Control

signal closed

const ButtonStyle = preload("res://scenes/button_style.gd")

var dim: ColorRect
var scroll: ScrollContainer
var body_label: Label
var close_button: Button


func _ready() -> void:
	position = Vector2.ZERO
	size = Vector2(1080, 1920)
	mouse_filter = Control.MOUSE_FILTER_STOP

	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	scroll = ScrollContainer.new()
	scroll.position = Vector2(60, 120)
	scroll.size = Vector2(960, 1560)
	add_child(scroll)

	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(920, 0)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 28)
	scroll.add_child(body_label)

	close_button = Button.new()
	close_button.position = Vector2(340, 1720)
	close_button.size = Vector2(400, 120)
	ButtonStyle.apply_to(close_button)
	close_button.add_theme_font_size_override("font_size", 48)
	close_button.pressed.connect(close)
	add_child(close_button)

	visible = false


func open(text: String, lang: String) -> void:
	body_label.text = text
	if lang == "ja":
		close_button.text = "閉じる"
	else:
		close_button.text = "CLOSE"
	scroll.scroll_vertical = 0
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func place(screen: Vector2) -> void:
	var offset = (screen - Vector2(1080, 1920)) / 2.0
	size = screen
	dim.size = screen
	scroll.position = Vector2(60, 120) + offset
	close_button.position = Vector2(340, 1720) + offset
