extends Label

const RULES_TEXT := "ONE ALIEN PER ROW, COLUMN AND COLOR.\nALIENS MUST NOT TOUCH, EVEN DIAGONALLY."
const RULES_TEXT_JA := "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。"

const ROCK_TEXT := "NO ALIEN ON A ? ROCK."
const ROCK_TEXT_JA := "? の岩には宇宙人を置けない。"
const RADAR_TEXT := "A NUMBER = ALIENS IN THE 8 CELLS AROUND IT."
const RADAR_TEXT_JA := "数字は、まわりの 8 マスにいる宇宙人の数。"

const FONT_SIZE := 32
const SMALL_FONT_SIZE := 24

var rules_lang: String = "en"
var has_rocks: bool = false
var has_numbers: bool = false

func _ready() -> void:
	text = RULES_TEXT
	visible = true
	z_index = 10
	add_theme_stylebox_override("normal", make_style_box())
	add_theme_color_override("font_color", text_color())

static func rules_text(lang_code: String, rocks: bool, numbers: bool) -> String:
	var base := RULES_TEXT_JA if lang_code == "ja" else RULES_TEXT
	var extras: Array[String] = []
	if rocks:
		extras.append(ROCK_TEXT_JA if lang_code == "ja" else ROCK_TEXT)
	if numbers:
		extras.append(RADAR_TEXT_JA if lang_code == "ja" else RADAR_TEXT)
	if extras.is_empty():
		return base
	return base + "\n" + " ".join(extras)

func apply_language(lang_code: String) -> void:
	rules_lang = lang_code
	text = rules_text(rules_lang, has_rocks, has_numbers)

func apply_level(level) -> void:
	if level != null and not level.asteroids.is_empty():
		has_rocks = true
	else:
		has_rocks = false
	
	if level != null and not level.radar.is_empty():
		has_numbers = true
	else:
		has_numbers = false
	
	text = rules_text(rules_lang, has_rocks, has_numbers)
	
	var font_size := FONT_SIZE
	var margin_top := 16.0
	var margin_bottom := 16.0
	
	if has_rocks or has_numbers:
		font_size = SMALL_FONT_SIZE
		margin_top = 6.0
		margin_bottom = 6.0
	
	add_theme_font_size_override("font_size", font_size)
	
	if has_theme_stylebox_override("normal"):
		var sb := get_theme_stylebox("normal")
		sb.content_margin_top = margin_top
		sb.content_margin_bottom = margin_bottom

static func make_style_box() -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load("res://assets/buttons/button_normal.png")
	sb.texture_margin_left = 32.0
	sb.texture_margin_right = 32.0
	sb.texture_margin_top = 44.0
	sb.texture_margin_bottom = 40.0
	sb.content_margin_left = 32.0
	sb.content_margin_right = 32.0
	sb.content_margin_top = 16.0
	sb.content_margin_bottom = 16.0
	return sb

static func text_color() -> Color:
	return Color("#4A320A")
