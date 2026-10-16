# 画面の層（SPEC.md 3 節）: 縦の画面（1080 x 1920）。入力を集めて session に渡し、状態を表示に写す。
# 規則・状態の判断は session（game/session.gd）に任せる。`session` は撮影（.autedev/shot.gd）が読む。
extends Node2D

signal tutorial_finished
signal title_requested

const Session = preload("res://game/session.gd")
const InputMapper = preload("res://scenes/input_mapper.gd")
const RulesLabelScript = preload("res://scenes/rules_label.gd")
const Tutorial = preload("res://game/tutorial.gd")
const SpaceBg = preload("res://scenes/space_bg.gd")

const HELP_TEXT := "TAP: X   DOUBLE TAP: PIECE   SWIPE: X"
const CLEARED_TEXT := "LEVEL CLEARED!  TAP FOR NEXT"

var session = null  # add_child の前に置けば、その session を使う（テスト用）
var _stroke: Array = []  # 今の指のなぞり [{"pos", "t"}]
var _prev_tap: Dictionary = {}
var rules_label: Label = null
var tutorial = null
var start_with_tutorial: bool = false
var space_bg = null
var language: String = "en"

@onready var board_view = $BoardView
@onready var hud = $Ui/Hud
@onready var bubble = $Ui/MessageBubble


func _ready() -> void:
	space_bg = SpaceBg.new()
	add_child(space_bg)
	move_child(space_bg, 0)

	if session == null:
		session = Session.new()
	board_view.session = session
	session.changed.connect(_refresh)
	hud.undo_pressed.connect(func() -> void: session.undo())
	hud.hint_pressed.connect(_on_hint)
	hud.settings_pressed.connect(func() -> void:
		if not is_tutorial():
			start_tutorial()
	)
	hud.apply_pressed.connect(on_apply)
	hud.restart_pressed.connect(func() -> void: session.restart_level())
	hud.title_requested.connect(on_title_requested)
	hud.set_language(language)
	_refresh()
	bubble.show_text(help_text(), 4.0)

	rules_label = RulesLabelScript.new()
	add_child(rules_label)
	rules_label.apply_language(language)
	rules_label.visible = true
	rules_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	rules_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	rules_label.add_theme_font_size_override("font_size", 36)
	rules_label.position = Vector2(54, 1730)
	rules_label.size = Vector2(972, 140)

	if start_with_tutorial:
		start_tutorial()


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
	if not is_tutorial() and session.status == "cleared":
		session.next_level()
		return
	if board_view.board_rect().has_point(pos):
		_stroke.append({"pos": pos, "t": Time.get_ticks_msec()})
	elif is_tutorial():
		tutorial_input("next", Vector2i(-1, -1))


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
			if is_tutorial():
				var step = tutorial.current_step()
				if not step.is_empty() and step.get("wait", {}).get("kind", "") == "next":
					tutorial_input("next", Vector2i(-1, -1))
				else:
					tutorial_input("tap", c)
			else:
				session.tap(c.x, c.y)
		"double_tap":
			if is_tutorial():
				var step = tutorial.current_step()
				if not step.is_empty() and step.get("wait", {}).get("kind", "") == "next":
					pass
				else:
					tutorial_input("double_tap", c)
			else:
				session.double_tap(c.x, c.y)
		"swipe":
			if not is_tutorial():
				session.swipe(r["cells"])


func _on_hint() -> void:
	if session.request_hint():
		bubble.show_text(session.current_hint["text"], 0.0)
		board_view.hint_cell = session.current_hint["cell"]
		hud.set_apply_visible(true)


func on_apply() -> void:
	bubble.clear_text()
	board_view.hint_cell = Vector2i(-1, -1)
	hud.set_apply_visible(false)
	session.apply_hint()


func _refresh() -> void:
	if not is_node_ready():
		return
	hud.update_from(session.snapshot())
	board_view.queue_redraw()
	if session.status == "cleared":
		bubble.show_text(cleared_text(), 0.0)
	elif bubble.text == cleared_text():
		bubble.clear_text()
	if session.current_hint.is_empty():
		board_view.hint_cell = Vector2i(-1, -1)
		hud.set_apply_visible(false)


func start_tutorial() -> void:
	tutorial = Tutorial.new()
	board_view.session = tutorial.session
	hud.set_tutorial_mode(true)
	var step = tutorial.current_step()
	if not step.is_empty():
		board_view.highlight_cells = step["highlight"]
		bubble.show_text(step["text"], 0.0)
	else:
		board_view.highlight_cells = []
		bubble.clear_text()
	board_view.queue_redraw()


func end_tutorial() -> void:
	tutorial = null
	board_view.session = session
	board_view.highlight_cells = []
	hud.set_tutorial_mode(false)
	bubble.show_text(help_text(), 4.0)
	_refresh()
	tutorial_finished.emit()


func is_tutorial() -> bool:
	return tutorial != null


func tutorial_input(kind: String, cell: Vector2i) -> void:
	if tutorial == null:
		return
	tutorial.handle(kind, cell)
	if tutorial.is_finished():
		end_tutorial()
	else:
		var step = tutorial.current_step()
		if not step.is_empty():
			board_view.highlight_cells = step["highlight"]
			bubble.show_text(step["text"], 0.0)
		else:
			board_view.highlight_cells = []
			bubble.clear_text()
		board_view.queue_redraw()


func help_text() -> String:
	if language == "ja":
		return "タップ: ×   ダブルタップ: 駒   スワイプ: ×"
	return HELP_TEXT


func cleared_text() -> String:
	if language == "ja":
		return "クリア！  タップで次の面"
	return CLEARED_TEXT


func on_title_requested() -> void:
	title_requested.emit()
