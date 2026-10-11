# 画面の層（SPEC.md 3 節）: 縦の画面（1080 x 1920）。入力を集めて session に渡し、状態を表示に写す。
# 規則・状態の判断は session（game/session.gd）に任せる。`session` は撮影（.autedev/shot.gd）が読む。
extends Node2D

const Session = preload("res://game/session.gd")
const InputMapper = preload("res://scenes/input_mapper.gd")
const RulesLabelScript = preload("res://scenes/rules_label.gd")

const HELP_TEXT := "TAP: X   DOUBLE TAP: PIECE   SWIPE: X"
const CLEARED_TEXT := "LEVEL CLEARED!  TAP FOR NEXT"

var session = null  # add_child の前に置けば、その session を使う（テスト用）
var _stroke: Array = []  # 今の指のなぞり [{"pos", "t"}]
var _prev_tap: Dictionary = {}
var rules_label: Label = null

@onready var board_view = $BoardView
@onready var hud = $Ui/Hud
@onready var bubble = $Ui/MessageBubble


func _ready() -> void:
	if session == null:
		session = Session.new()
	board_view.session = session
	session.changed.connect(_refresh)
	hud.undo_pressed.connect(func() -> void: session.undo())
	hud.hint_pressed.connect(_on_hint)
	hud.settings_pressed.connect(func() -> void: bubble.show_text("SETTINGS: COMING SOON", 2.0))
	_refresh()
	bubble.show_text(HELP_TEXT, 4.0)

	rules_label = RulesLabelScript.new()
	add_child(rules_label)
	rules_label.text = RulesLabelScript.RULES_TEXT
	rules_label.visible = true
	rules_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	rules_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# Position the label below the board area to avoid overlap.
	# Assuming standard 1080x1920 layout where board is centered or top-aligned,
	# and HINT button is above y=1720.
	# We place it at y=1720 with a width that fits the screen.
	var viewport_size := get_viewport().get_visible_rect().size
	var label_width := viewport_size.x * 0.9
	var label_height := 100.0 # Approximate height for 2 lines of text
	
	rules_label.position = Vector2((viewport_size.x - label_width) / 2.0, 1720.0)
	rules_label.size = Vector2(label_width, label_height)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == 0:
		if event.pressed:
			_on_touch_down(event.position)
		else:
			_on_touch_up(event.position)
	elif event is InputEventScreenDrag and event.index == 0 and not _stroke.is_empty():
		_stroke.append({"pos": event.position, "t": Time.get_ticks_msec()})


func _on_touch_down(pos: Vector2) -> void:
	_stroke = []
	if session.status == "cleared":
		session.next_level()
		return
	if board_view.board_rect().has_point(pos):
		_stroke.append({"pos": pos, "t": Time.get_ticks_msec()})


func _on_touch_up(pos: Vector2) -> void:
	if _stroke.is_empty():
		return
	_stroke.append({"pos": pos, "t": Time.get_ticks_msec()})
	var r := InputMapper.classify(_stroke, _prev_tap, board_view.geometry())
	_stroke = []
	_prev_tap = r["tap_record"]
	var c: Vector2i = r["cell"]
	match r["kind"]:
		"tap":
			session.tap(c.x, c.y)
		"double_tap":
			session.double_tap(c.x, c.y)
		"swipe":
			session.swipe(r["cells"])


func _on_hint() -> void:
	if session.use_hint():
		bubble.show_text("HINT: COMING SOON", 2.0)


func _refresh() -> void:
	if not is_node_ready():
		return
	hud.update_from(session.snapshot())
	board_view.queue_redraw()
	if session.status == "cleared":
		bubble.show_text(CLEARED_TEXT, 0.0)
	elif bubble.text == CLEARED_TEXT:
		bubble.clear_text()
