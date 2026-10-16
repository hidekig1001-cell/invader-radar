extends Control

signal start_requested(with_tutorial: bool)

var _language: String = ""
var _title_label: Label
var _lang_btn_en: Button
var _lang_btn_ja: Button
var _start_btn_tutorial: Button
var _start_btn_now: Button
var background: TextureRect

func _ready() -> void:
	size = Vector2(1080, 1920)

	background = TextureRect.new()
	var tex = load("res://assets/title_bg_1080x1920.png")
	if tex != null:
		background.texture = tex
	background.position = Vector2(0, 0)
	background.size = Vector2(1080, 1920)
	add_child(background)

	_title_label = Label.new()
	_title_label.text = "INVADER RADAR"
	_title_label.position = Vector2(0, 480)
	_title_label.size = Vector2(1080, 160)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 96)
	add_child(_title_label)

	_lang_btn_en = Button.new()
	_lang_btn_en.text = "English"
	_lang_btn_en.position = Vector2(150, 880)
	_lang_btn_en.size = Vector2(360, 140)
	_lang_btn_en.add_theme_font_size_override("font_size", 56)
	_lang_btn_en.pressed.connect(func(): select_language("en"))
	add_child(_lang_btn_en)

	_lang_btn_ja = Button.new()
	_lang_btn_ja.text = "日本語"
	_lang_btn_ja.position = Vector2(570, 880)
	_lang_btn_ja.size = Vector2(360, 140)
	_lang_btn_ja.add_theme_font_size_override("font_size", 56)
	_lang_btn_ja.pressed.connect(func(): select_language("ja"))
	add_child(_lang_btn_ja)

	_start_btn_tutorial = Button.new()
	_start_btn_tutorial.position = Vector2(150, 1200)
	_start_btn_tutorial.size = Vector2(780, 160)
	_start_btn_tutorial.add_theme_font_size_override("font_size", 60)
	_start_btn_tutorial.visible = false
	_start_btn_tutorial.pressed.connect(func(): press_start(true))
	add_child(_start_btn_tutorial)

	_start_btn_now = Button.new()
	_start_btn_now.position = Vector2(150, 1400)
	_start_btn_now.size = Vector2(780, 160)
	_start_btn_now.add_theme_font_size_override("font_size", 60)
	_start_btn_now.visible = false
	_start_btn_now.pressed.connect(func(): press_start(false))
	add_child(_start_btn_now)

func title_text() -> String:
	return _title_label.text

func language_labels() -> Array:
	return [_lang_btn_en.text, _lang_btn_ja.text]

func select_language(lang: String) -> void:
	_language = lang
	if lang == "en":
		_start_btn_tutorial.text = "START WITH TUTORIAL"
		_start_btn_now.text = "START NOW"
	elif lang == "ja":
		_start_btn_tutorial.text = "チュートリアルから始める"
		_start_btn_now.text = "すぐに始める"
	_start_btn_tutorial.visible = true
	_start_btn_now.visible = true

func language() -> String:
	return _language

func start_buttons_visible() -> bool:
	return _start_btn_tutorial.visible and _start_btn_now.visible

func start_labels() -> Array:
	return [_start_btn_tutorial.text, _start_btn_now.text]

func press_start(with_tutorial: bool) -> void:
	start_requested.emit(with_tutorial)
