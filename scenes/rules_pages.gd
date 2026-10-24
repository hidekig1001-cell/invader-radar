extends Control

signal finished

const ButtonStyle = preload("res://scenes/button_style.gd")

const PAGE_IMAGES := [
	preload("res://assets/rules/rules_1.png"),
	preload("res://assets/rules/rules_2.png"),
	preload("res://assets/rules/rules_3.png"),
	preload("res://assets/rules/rules_4.png"),
	preload("res://assets/rules/rules_5.png"),
	preload("res://assets/rules/rules_6.png"),
	preload("res://assets/rules/rules_7.png")
]

const PAGE_TEXT_EN := [
	"PLACE THE ALIEN PIECES ON THE BOARD.\nKEEP ALL THE RULES TO CLEAR IT!",
	"ONE PIECE IN EACH COLOR AREA.",
	"ONE PIECE IN EACH ROW\nAND IN EACH COLUMN.",
	"PIECES MUST NOT TOUCH,\nNOT EVEN DIAGONALLY.",
	"A NUMBER TELLS HOW MANY PIECES\nARE IN THE 8 CELLS AROUND IT.",
	"YOU CANNOT PLACE A PIECE\nON A ROCK.",
	"TAP ONCE TO MARK X.\nDOUBLE TAP TO PLACE A PIECE."
]

const PAGE_TEXT_JA := [
	"盤のマスに宇宙人の駒を置こう。\nルールを全部守るとクリア！",
	"同じ色のマスの集まりに、\n駒は 1 つずつ。",
	"横の 1 行・縦の 1 列にも、\n駒は 1 つずつ。",
	"駒どうしは、縦・横・斜めに\n隣り合えない。",
	"数字は、まわりの 8 マスにある\n駒の数。",
	"岩のマスには、\n駒を置けない。",
	"1 回タップで × を付ける。\n2 回タップで駒を置く。"
]

var language: String = "en"
var page_index: int = 0

var bg: ColorRect
var image: TextureRect
var text_label: Label
var page_label: Label
var back_btn: Button
var next_btn: Button

func _ready() -> void:
	size = Vector2(1080, 1920)
	
	bg = ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.20)
	bg.size = size
	add_child(bg)
	
	text_label = Label.new()
	text_label.position = Vector2(60, 140)
	text_label.size = Vector2(960, 240)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", 44)
	add_child(text_label)
	
	image = TextureRect.new()
	image.position = Vector2(60, 420)
	image.size = Vector2(960, 720)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(image)
	
	page_label = Label.new()
	page_label.position = Vector2(60, 1170)
	page_label.size = Vector2(960, 60)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.add_theme_font_size_override("font_size", 36)
	add_child(page_label)
	
	back_btn = Button.new()
	back_btn.position = Vector2(60, 1280)
	back_btn.size = Vector2(440, 130)
	back_btn.add_theme_font_size_override("font_size", 48)
	back_btn.pressed.connect(prev_page)
	add_child(back_btn)
	
	next_btn = Button.new()
	next_btn.position = Vector2(580, 1280)
	next_btn.size = Vector2(440, 130)
	next_btn.add_theme_font_size_override("font_size", 48)
	next_btn.pressed.connect(next_page)
	add_child(next_btn)
	
	ButtonStyle.apply_to(back_btn)
	ButtonStyle.apply_to(next_btn)
	
	show_page(0)

func page_count() -> int:
	return PAGE_IMAGES.size()

func page_text(i: int) -> String:
	if language == "ja":
		return PAGE_TEXT_JA[i]
	else:
		return PAGE_TEXT_EN[i]

func show_page(i: int) -> void:
	page_index = clampi(i, 0, page_count() - 1)
	image.texture = PAGE_IMAGES[page_index]
	text_label.text = page_text(page_index)
	page_label.text = "%d / %d" % [page_index + 1, page_count()]
	
	if language == "ja":
		back_btn.text = "もどる"
	else:
		back_btn.text = "BACK"
		
	if page_index == 0:
		back_btn.disabled = true
	else:
		back_btn.disabled = false
		
	if page_index == page_count() - 1:
		if language == "ja":
			next_btn.text = "はじめる"
		else:
			next_btn.text = "START"
	else:
		if language == "ja":
			next_btn.text = "つぎへ"
		else:
			next_btn.text = "NEXT"

func next_page() -> void:
	if page_index == page_count() - 1:
		finished.emit()
	else:
		show_page(page_index + 1)

func prev_page() -> void:
	if page_index > 0:
		show_page(page_index - 1)

func place(screen: Vector2) -> void:
	size = screen
	bg.size = screen
	position = Vector2(0, 0)
	var dy = maxf(0.0, (screen.y - 1920.0) / 2.0)
	text_label.position.y += dy
	image.position.y += dy
	page_label.position.y += dy
	back_btn.position.y += dy
	next_btn.position.y += dy
