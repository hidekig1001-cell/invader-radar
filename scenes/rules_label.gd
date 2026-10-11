extends Label

const RULES_TEXT := "ONE PIECE PER ROW, COLUMN AND COLOR.\nPIECES MUST NOT TOUCH, EVEN DIAGONALLY."

func _ready() -> void:
	text = RULES_TEXT
	visible = true
