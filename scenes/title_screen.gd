extends Control

signal start_requested(with_tutorial: bool)
signal fresh_start_requested
signal quit_requested

const Sound = preload("res://scenes/sound.gd")
const ButtonStyle = preload("res://scenes/button_style.gd")
const SpaceBg = preload("res://scenes/space_bg.gd")
const SoundSettings = preload("res://game/sound_settings.gd")
const Licenses = preload("res://game/licenses.gd")
const LicensesPanel = preload("res://scenes/licenses_panel.gd")

var _language: String = ""
var _title_label: Label
var title_logo: TextureRect
var _lang_btn_en: Button
var _lang_btn_ja: Button
var _start_btn_tutorial: Button
var _start_btn_now: Button
var _start_btn_fresh: Button
var background: TextureRect
var top_fill: ColorRect
var sound = null
var base_positions: Dictionary = {}
var settings_path: String = "user://settings.json"
var muted: bool = false
var sound_btn: Button
var licenses_btn: Button
var licenses_panel = null
var safe_top: float = 0.0

func _ready() -> void:
	size = Vector2(1080, 1920)

	background = TextureRect.new()
	var tex = load("res://assets/title_bg_1080x1920.png")
	if tex != null:
		background.texture = tex
	background.position = Vector2(0, 120)
	background.size = Vector2(1080, 1800)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(background)

	top_fill = ColorRect.new()
	top_fill.color = Color(0.03, 0.02, 0.12)
	top_fill.position = Vector2(0, 0)
	top_fill.size = Vector2(1080, 120)
	add_child(top_fill)

	sound = Sound.new()
	add_child(sound)
	sound.setup()

	muted = SoundSettings.load_muted(settings_path)
	SoundSettings.apply(muted)

	sound.play_music("bgm_title")

	_title_label = Label.new()
	_title_label.text = "INVADER RADAR"
	_title_label.position = Vector2(0, 480)
	_title_label.size = Vector2(1080, 160)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 96)
	add_child(_title_label)

	title_logo = TextureRect.new()
	title_logo.texture = load("res://assets/title_logo.png")
	title_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_logo.position = Vector2(180, 520)
	title_logo.size = Vector2(720, 323)
	add_child(title_logo)

	_title_label.visible = false

	_lang_btn_en = Button.new()
	_lang_btn_en.text = "English"
	_lang_btn_en.position = Vector2(150, 880)
	_lang_btn_en.size = Vector2(360, 140)
	_lang_btn_en.add_theme_font_size_override("font_size", 56)
	_lang_btn_en.pressed.connect(func(): 
		sound.play_sfx("button")
		select_language("en")
	)
	add_child(_lang_btn_en)
	ButtonStyle.apply_to(_lang_btn_en)

	_lang_btn_ja = Button.new()
	_lang_btn_ja.text = "日本語"
	_lang_btn_ja.position = Vector2(570, 880)
	_lang_btn_ja.size = Vector2(360, 140)
	_lang_btn_ja.add_theme_font_size_override("font_size", 56)
	_lang_btn_ja.pressed.connect(func(): 
		sound.play_sfx("button")
		select_language("ja")
	)
	add_child(_lang_btn_ja)
	ButtonStyle.apply_to(_lang_btn_ja)

	_start_btn_tutorial = Button.new()
	_start_btn_tutorial.position = Vector2(150, 1200)
	_start_btn_tutorial.size = Vector2(780, 160)
	_start_btn_tutorial.add_theme_font_size_override("font_size", 60)
	_start_btn_tutorial.visible = false
	_start_btn_tutorial.pressed.connect(func(): 
		sound.play_sfx("button")
		press_start(true)
	)
	add_child(_start_btn_tutorial)
	ButtonStyle.apply_to(_start_btn_tutorial)

	_start_btn_now = Button.new()
	_start_btn_now.position = Vector2(150, 1400)
	_start_btn_now.size = Vector2(780, 160)
	_start_btn_now.add_theme_font_size_override("font_size", 60)
	_start_btn_now.visible = false
	_start_btn_now.pressed.connect(func(): 
		sound.play_sfx("button")
		press_start(false)
	)
	add_child(_start_btn_now)
	ButtonStyle.apply_to(_start_btn_now)

	_start_btn_fresh = Button.new()
	_start_btn_fresh.position = Vector2(150, 1600)
	_start_btn_fresh.size = Vector2(780, 160)
	_start_btn_fresh.add_theme_font_size_override("font_size", 60)
	_start_btn_fresh.visible = false
	_start_btn_fresh.pressed.connect(func(): 
		sound.play_sfx("button")
		press_fresh_start()
	)
	add_child(_start_btn_fresh)
	ButtonStyle.apply_to(_start_btn_fresh)

	sound_btn = Button.new()
	sound_btn.position = Vector2(570, 1080)
	sound_btn.size = Vector2(360, 90)
	sound_btn.add_theme_font_size_override("font_size", 44)
	sound_btn.pressed.connect(func(): 
		sound.play_sfx("button")
		toggle_sound()
	)
	add_child(sound_btn)
	ButtonStyle.apply_to(sound_btn)
	update_sound_label()

	licenses_btn = Button.new()
	licenses_btn.text = "LICENSES"
	licenses_btn.position = Vector2(150, 1080)
	licenses_btn.size = Vector2(360, 90)
	licenses_btn.add_theme_font_size_override("font_size", 36)
	licenses_btn.pressed.connect(func(): 
		sound.play_sfx("button")
		open_licenses()
	)
	add_child(licenses_btn)
	ButtonStyle.apply_to(licenses_btn)

	licenses_panel = LicensesPanel.new()
	add_child(licenses_panel)

	base_positions["title"] = _title_label.position
	base_positions["title_logo"] = title_logo.position
	base_positions["lang_en"] = _lang_btn_en.position
	base_positions["lang_ja"] = _lang_btn_ja.position
	base_positions["start_tut"] = _start_btn_tutorial.position
	base_positions["start_now"] = _start_btn_now.position
	base_positions["start_fresh"] = _start_btn_fresh.position
	base_positions["sound"] = sound_btn.position
	base_positions["licenses"] = licenses_btn.position

	var visible_size = get_viewport().get_visible_rect().size
	var display_name = DisplayServer.get_name()
	var layout_size = SpaceBg.screen_size_for_layout(visible_size, display_name)
	if display_name != "headless":
		safe_top = SpaceBg.safe_top_for_layout(float(DisplayServer.get_display_safe_area().position.y), float(DisplayServer.window_get_size().y), layout_size.y)
	apply_screen_layout(layout_size)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit_requested.emit()

func apply_screen_layout(size: Vector2) -> void:
	var offset = SpaceBg.safe_layout_offsets(size.x, size.y, safe_top)
	
	background.size = Vector2(size.x, size.y - 120 - offset.y)
	background.position = Vector2(0, 120 + offset.y)
	top_fill.size = Vector2(size.x, 120 + offset.y)
	
	if base_positions.has("title"):
		_title_label.position = base_positions["title"] + offset
	if base_positions.has("title_logo"):
		title_logo.position = base_positions["title_logo"] + offset
	if base_positions.has("lang_en"):
		_lang_btn_en.position = base_positions["lang_en"] + offset
	if base_positions.has("lang_ja"):
		_lang_btn_ja.position = base_positions["lang_ja"] + offset
	if base_positions.has("start_tut"):
		_start_btn_tutorial.position = base_positions["start_tut"] + offset
	if base_positions.has("start_now"):
		_start_btn_now.position = base_positions["start_now"] + offset
	if base_positions.has("start_fresh"):
		_start_btn_fresh.position = base_positions["start_fresh"] + offset
	if base_positions.has("sound"):
		sound_btn.position = base_positions["sound"] + offset
	if base_positions.has("licenses"):
		licenses_btn.position = base_positions["licenses"] + offset
		if licenses_panel != null:
			licenses_panel.place(size)

func title_text() -> String:
	return _title_label.text

func language_labels() -> Array:
	return [_lang_btn_en.text, _lang_btn_ja.text]

func select_language(lang: String) -> void:
	_language = lang
	if lang == "en":
		_start_btn_tutorial.text = "START WITH TUTORIAL"
		_start_btn_now.text = "START NOW"
		_start_btn_fresh.text = "START OVER"
	elif lang == "ja":
		_start_btn_tutorial.text = "チュートリアルから始める"
		_start_btn_now.text = "すぐに始める"
		_start_btn_fresh.text = "1面からやり直す"
	_start_btn_tutorial.visible = true
	_start_btn_now.visible = true
	_start_btn_fresh.visible = true
	update_sound_label()
	if lang == "ja":
		licenses_btn.text = "ライセンス"
	else:
		licenses_btn.text = "LICENSES"

func language() -> String:
	return _language

func start_buttons_visible() -> bool:
	return _start_btn_tutorial.visible and _start_btn_now.visible

func start_labels() -> Array:
	return [_start_btn_tutorial.text, _start_btn_now.text]

func press_start(with_tutorial: bool) -> void:
	sound.stop_music()
	start_requested.emit(with_tutorial)

func press_fresh_start() -> void:
	sound.stop_music()
	fresh_start_requested.emit()

func toggle_sound() -> void:
	muted = not muted
	SoundSettings.save_muted(settings_path, muted)
	SoundSettings.apply(muted)
	update_sound_label()

# 押したときにどうなるかを出す（鳴っているとき OFF、消音のとき ON）。
func sound_label() -> String:
	if _language == "ja":
		if muted:
			return "音 ON"
		else:
			return "音 OFF"
	else:
		if muted:
			return "SOUND ON"
		else:
			return "SOUND OFF"

func update_sound_label() -> void:
	if sound_btn != null:
		sound_btn.text = sound_label()

func open_licenses() -> void:
	licenses_panel.open(Licenses.full_text(), _language)
