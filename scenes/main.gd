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
const Rules = preload("res://core/rules.gd")
const Sound = preload("res://scenes/sound.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")
const SessionSave = preload("res://game/session_save.gd")

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
var sound = null
var last_snapshot: Dictionary = {}
var last_conflicts: int = 0
var save_path := ""
var clear_effect = null
var last_status: String = ""
var last_tutorial_status: String = ""

@onready var board_view = $BoardView
@onready var hud = $Ui/Hud
@onready var bubble = $Ui/MessageBubble

var base_positions: Dictionary = {}


func _ready() -> void:
	sound = Sound.new()
	add_child(sound)
	sound.setup()
	sound.play_music("bgm_main")

	space_bg = SpaceBg.new()
	add_child(space_bg)
	move_child(space_bg, 0)

	if session == null:
		session = Session.new()
	
	if save_path != "":
		var data = SessionSave.read_json(save_path)
		if not data.is_empty():
			session.restore_dict(data)

	board_view.session = session
	
	clear_effect = preload("res://scenes/clear_effect.gd").new()
	add_child(clear_effect)
	
	session.changed.connect(_refresh)
	hud.undo_pressed.connect(func() -> void:
		sound.play_sfx("button")
		session.undo()
	)
	hud.hint_pressed.connect(_on_hint)
	hud.settings_pressed.connect(func() -> void:
		sound.play_sfx("button")
		if not is_tutorial():
			start_tutorial()
	)
	hud.apply_pressed.connect(on_apply)
	hud.restart_pressed.connect(func() -> void: session.restart_level())
	hud.title_requested.connect(on_title_requested)
	hud.solve_pressed.connect(func() -> void:
		if not is_tutorial():
			session.solve_now()
	)
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

	# CR-1039: Record base positions before applying layout offsets
	base_positions["hud"] = hud.position
	base_positions["board_view"] = board_view.position
	base_positions["bubble"] = bubble.position
	base_positions["rules_label"] = rules_label.position

	var visible_size = get_viewport().get_visible_rect().size
	var display_name = DisplayServer.get_name()
	var layout_size = SpaceBg.screen_size_for_layout(visible_size, display_name)
	apply_screen_layout(layout_size)

	if start_with_tutorial:
		start_tutorial()


func save_progress() -> void:
	if save_path != "":
		SessionSave.write_json(save_path, session.save_dict())


func apply_screen_layout(size: Vector2) -> void:
	var offsets = SpaceBg.layout_offsets(size.x, size.y)
	var extra_x = offsets.x * 2.0
	var extra_y = offsets.y * 2.0
	
	# Apply offsets to parts based on base positions
	if base_positions.has("hud"):
		hud.position = base_positions["hud"] + Vector2(extra_x / 2.0, extra_y / 2.0)
	if base_positions.has("board_view"):
		board_view.position = base_positions["board_view"] + Vector2(extra_x / 2.0, extra_y / 2.0)
	if base_positions.has("bubble"):
		bubble.position = base_positions["bubble"] + Vector2(extra_x / 2.0, extra_y / 2.0)
	if base_positions.has("rules_label"):
		rules_label.position = base_positions["rules_label"] + Vector2(extra_x / 2.0, extra_y / 2.0)
		
	space_bg.sky_size = size
	space_bg.avoid_rects = part_rects()


func part_rects() -> Array:
	var rects = []
	
	# Rules Label
	if rules_label:
		rects.append(Rect2(rules_label.position, rules_label.size))
		
	# Board View
	if board_view:
		var b_rect = board_view.board_rect()
		var global_b_rect = Rect2(board_view.position + b_rect.position, b_rect.size)
		rects.append(global_b_rect)

	# HUD
	if hud:
		if hud is Control:
			rects.append(Rect2(hud.position, hud.size))
		else:
			pass

	return rects


func to_board_pos(pos: Vector2) -> Vector2:
	return pos - board_view.global_position


func is_on_board(pos: Vector2) -> bool:
	var local_pos = to_board_pos(pos)
	return board_view.board_rect().has_point(local_pos)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == 0:
		if event.pressed:
			_on_touch_down(event.position)
		else:
			_on_touch_up(event.position)
	elif event is InputEventScreenDrag and event.index == 0 and not _stroke.is_empty():
		var local_pos = to_board_pos(event.position)
		_stroke.append({"pos": local_pos, "t": Time.get_ticks_msec()})


func _on_touch_down(pos: Vector2) -> void:
	_stroke = []
	if not is_tutorial() and session.status == "cleared":
		session.next_level()
		save_progress()
		return
	
	var local_pos = to_board_pos(pos)
	if board_view.board_rect().has_point(local_pos):
		_stroke.append({"pos": local_pos, "t": Time.get_ticks_msec()})
	elif is_tutorial():
		tutorial_input("next", Vector2i(-1, -1))


func _on_touch_up(pos: Vector2) -> void:
	if _stroke.is_empty():
		return
	
	var local_pos = to_board_pos(pos)
	_stroke.append({"pos": local_pos, "t": Time.get_ticks_msec()})
	
	var r := InputMapper.classify(_stroke, _prev_tap, board_view.geometry())
	_stroke = []
	_prev_tap = r["tap_record"]
	var c: Vector2i = r["cell"]
	if is_tutorial() and r["kind"] != "swipe" and not tutorial_accepts_cell(c):
		return
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
	sound.play_sfx("button")
	bubble.clear_text()
	board_view.hint_cell = Vector2i(-1, -1)
	hud.set_apply_visible(false)
	session.apply_hint()


func _refresh() -> void:
	if not is_node_ready():
		return
	var curr_snapshot
	var curr_conflicts
	if is_tutorial():
		curr_snapshot = tutorial.session.snapshot()
		curr_conflicts = Rules.conflicts(tutorial.session.board, tutorial.session.level).size()
	else:
		curr_snapshot = session.snapshot()
		curr_conflicts = Rules.conflicts(session.board, session.level).size()
	var sfx_name = Sound.sfx_for(last_snapshot, curr_snapshot, last_conflicts, curr_conflicts)
	if sfx_name != "":
		sound.play_sfx(sfx_name)
	last_snapshot = curr_snapshot
	last_conflicts = curr_conflicts

	hud.update_from(curr_snapshot)
	board_view.queue_redraw()
	
	if not is_tutorial() and session.status == "cleared" and last_status != "cleared":
		clear_effect.play(board_view.position + board_view.board_rect().get_center())
	last_status = session.status
	
	if is_tutorial():
		if tutorial.session.status == "cleared" and last_tutorial_status != "cleared":
			clear_effect.play(board_view.position + board_view.board_rect().get_center())
		last_tutorial_status = tutorial.session.status
	
	if not is_tutorial() and session.status == "cleared":
		bubble.show_tile(cleared_text(), board_view.position + board_view.board_rect().get_center())
	elif bubble.text == cleared_text():
		bubble.clear_text()
	if session.current_hint.is_empty():
		board_view.hint_cell = Vector2i(-1, -1)
		hud.set_apply_visible(false)


func start_tutorial() -> void:
	bubble.clear_text()
	tutorial = Tutorial.new()
	board_view.session = tutorial.session
	last_snapshot = tutorial.session.snapshot()
	last_conflicts = Rules.conflicts(tutorial.session.board, tutorial.session.level).size()
	tutorial.session.changed.connect(_refresh)
	hud.set_tutorial_mode(true)
	var step = tutorial.current_step()
	if not step.is_empty():
		board_view.highlight_cells = step["highlight"]
		bubble.show_text(TutorialSteps.apply_language(language, tutorial.step_index), 0.0)
	else:
		board_view.highlight_cells = []
		bubble.clear_text()
	board_view.queue_redraw()


func end_tutorial() -> void:
	if tutorial != null:
		tutorial.session.changed.disconnect(_refresh)
	tutorial = null
	board_view.session = session
	last_snapshot = session.snapshot()
	last_conflicts = Rules.conflicts(session.board, session.level).size()
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
			bubble.show_text(TutorialSteps.apply_language(language, tutorial.step_index), 0.0)
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

func _process(delta: float) -> void:
	if session == null or is_tutorial():
		return
	session.tick(delta)
	hud.set_time(session.elapsed)

func tutorial_accepts_cell(cell: Vector2i) -> bool:
	if tutorial == null:
		return true
	var step = tutorial.current_step()
	if step.is_empty():
		return true
	var highlights = step.get("highlight", [])
	if highlights.is_empty():
		return true
	return cell in highlights
