extends Label

const RULES_TEXT := "ONE PIECE PER ROW, COLUMN AND COLOR.\nPIECES MUST NOT TOUCH, EVEN DIAGONALLY."
const RULES_TEXT_JA := "各行・各列・各色に駒を 1 つ置く。\n駒どうしは縦・横・斜めにも隣り合ってはいけない。"

func _ready() -> void:
	text = RULES_TEXT
	visible = true
	z_index = 10
	add_theme_stylebox_override("normal", make_style_box())
	add_theme_color_override("font_color", text_color())

func apply_language(lang_code: String) -> void:
	if lang_code == "ja":
		text = RULES_TEXT_JA
	else:
		text = RULES_TEXT

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
