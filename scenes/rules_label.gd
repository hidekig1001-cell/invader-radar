extends Label

const RULES_TEXT := "ONE PIECE PER ROW, COLUMN AND COLOR.\nPIECES MUST NOT TOUCH, EVEN DIAGONALLY."
const RULES_TEXT_JA := "各行・各列・各色に駒を 1 つ置く。\n駒どうしは縦・横・斜めにも隣り合ってはいけない。"

func _ready() -> void:
	text = RULES_TEXT
	visible = true

func apply_language(lang_code: String) -> void:
	if lang_code == "ja":
		text = RULES_TEXT_JA
	else:
		text = RULES_TEXT
