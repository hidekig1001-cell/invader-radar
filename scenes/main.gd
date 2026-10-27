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
const RulesPanel = preload("res://scenes/rules_panel.gd")
const ProgressStore = preload("res://game/progress_store.gd")

# 操作の説明は項目の途中で折り返さないよう、項目の区切りで改行しておく。
const HELP_TEXT := "TAP: X   DOUBLE TAP: ALIEN\nSWIPE: X"
const CLEARED_TEXT := "LEVEL CLEARED!  TAP FOR NEXT"
const ALL_CLEARED_TEXT := "ALL LEVELS CLEARED!  TAP FOR TITLE"
const LOGO_GAP := 20.0

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
var last_dead_marks: Array = []
var last_lines: Array = []
var save_path := ""
var progress_store = null
var clear_effect = null
var last_status: String = ""
var last_tutorial_status: String = ""
var safe_top: float = 0.0

@onready var board_view = $BoardView
@onready var hud = $Ui/Hud
@onready var bubble = $Ui/MessageBubble

var base_positions: Dictionary = {}
var rules_panel = null
var title_logo: TextureRect = null

var size_up_wait: float = 0.0
var size_up_age: float = 0.0


func _ready() -> void:
	sound = Sound.new()
	add_child(sound)
	sound.setup()

	space_bg = SpaceBg.new()
	add_child(space_bg)
	move_child(space_bg, 0)

	if session == null:
		session = Session.new()
	
	if save_path != "":
		var data = current_store().load_progress()
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
			open_rules()
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
	show_help()
	update_music()

	rules_label = RulesLabelScript.new()
	add_child(rules_label)
	rules_label.apply_language(language)
	rules_label.visible = true
	rules_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	rules_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	rules_label.add_theme_font_size_override("font_size", 32)
	rules_label.position = Vector2(54, 1732)
	rules_label.size = Vector2(972, 128)
	update_rules_label()

	title_logo = TextureRect.new()
	title_logo.texture = load("res://assets/title_logo/title_logo_1000x200.png")
	title_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	title_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.get_parent().add_child(title_logo)

	# CR-1039: Record base positions before applying layout offsets
	base_positions["hud"] = hud.position
	base_positions["board_view"] = board_view.position
	base_positions["bubble"] = bubble.position
	base_positions["rules_label"] = rules_label.position

	rules_panel = RulesPanel.new()
	hud.get_parent().add_child(rules_panel)

	var visible_size = get_viewport().get_visible_rect().size
	var display_name = DisplayServer.get_name()
	var layout_size = SpaceBg.screen_size_for_layout(visible_size, display_name)
	if display_name != "headless":
		safe_top = SpaceBg.safe_top_for_layout(float(DisplayServer.get_display_safe_area().position.y), float(DisplayServer.window_get_size().y), layout_size.y)
	apply_screen_layout(layout_size)

	if start_with_tutorial:
		start_tutorial()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_back()


func current_store():
	if progress_store != null:
		return progress_store
	var store = ProgressStore.new()
	store.path = save_path
	return store


func save_progress() -> void:
	if save_path != "":
		current_store().save_progress(session.save_dict())


func apply_screen_layout(size: Vector2) -> void:
	var offsets = SpaceBg.safe_layout_offsets(size.x, size.y, safe_top)
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
		
	place_title_logo()
	if rules_panel != null:
		rules_panel.place(size)
	space_bg.sky_size = size
	space_bg.avoid_rects = part_rects()


func place_title_logo() -> void:
	if title_logo == null:
		return
	var top_space: float = hud.position.y + 90.0
	var h: float = minf(152.0, top_space - 40.0)
	if h < 100.0:
		title_logo.visible = false
		space_bg.pink_min_y = 0.0
		return
	else:
		title_logo.visible = true
		title_logo.size = Vector2(h * 5.0, h)
		title_logo.position = Vector2(hud.position.x + 1040.0 - h * 5.0, top_space - h - LOGO_GAP)
		space_bg.pink_min_y = title_logo.position.y


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

	if title_logo != null and title_logo.visible:
		rects.append(Rect2(title_logo.position, title_logo.size))

	# HUD
	if hud:
		if hud is Control:
			if title_logo != null and title_logo.visible:
				rects.append(Rect2(hud.position + Vector2(0, 90), hud.size - Vector2(0, 90)))
			else:
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
	if rules_is_open():
		return
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
	if not is_tutorial() and size_up_wait > 0.0:
		return

	if not is_tutorial() and bubble.tile_mode and size_up_tile_text() != "" and bubble.text == size_up_tile_text():
		if size_up_age < 0.8:
			return
		bubble.clear_text()
		show_help()
		return

	if not is_tutorial() and session.status == "cleared":
		var was_last := is_last_level()
		session.next_level()
		save_progress()
		if was_last:
			on_title_requested()
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
				if rock_ng(c.x, c.y):
					return
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
	if is_tutorial():
		return
	if session.request_hint():
		bubble.show_text(hint_text(session.current_hint["text"]), 0.0)
		board_view.hint_cell = session.current_hint["cell"]


func on_apply() -> void:
	sound.play_sfx("button")
	show_help()
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
	if last_snapshot.is_empty():
		sfx_name = ""
	
	var curr_dead_marks: Array = []
	if not is_tutorial():
		curr_dead_marks = Rules.dead_marks(session.board, session.level)
		var has_new_dead := false
		for mark in curr_dead_marks:
			if not last_dead_marks.has(mark):
				has_new_dead = true
				break
		if (sfx_name == "mark" or sfx_name == "clear") and not last_snapshot.is_empty() and has_new_dead:
			sfx_name = "dead"
			
	var curr_lines: Array = []
	if not is_tutorial():
		curr_lines = Rules.filled_lines(session.board, session.level)
	else:
		curr_lines = []
		
	var new_lines: Array = []
	for line in curr_lines:
		if not last_lines.has(line):
			new_lines.append(line)
			
	if sfx_name in ["clear", "place", "mark"] and not last_snapshot.is_empty() and not new_lines.is_empty():
		sfx_name = "line"
			
	if sfx_name != "":
		sound.play_sfx(sfx_name)
		if sfx_name == "place":
			sound.vibrate(30)
		elif sfx_name == "mark":
			sound.vibrate(15, 0.4)
		elif sfx_name == "dead":
			sound.vibrate(250, 0.3)
		elif sfx_name == "wrong":
			sound.vibrate(250, 0.3)
		if sfx_name == "line":
			board_view.flash_lines(new_lines)
			
	last_snapshot = curr_snapshot
	last_conflicts = curr_conflicts
	last_dead_marks = curr_dead_marks
	last_lines = curr_lines

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
		var tile_text = size_up_tile_text()
		if tile_text != "":
			size_up_wait = 0.6
		else:
			show_help()
	if session.current_hint.is_empty():
		if board_view.hint_cell.x >= 0 and session.status != "cleared":
			show_help()
		board_view.hint_cell = Vector2i(-1, -1)
		hud.set_apply_visible(false)

	if not is_tutorial() and session.status != "cleared" and session.current_hint.is_empty():
		var current_text = bubble.text
		var target_text = help_text()
		if current_text != target_text:
			var ja_help = "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×"
			if current_text == HELP_TEXT or current_text == ja_help or current_text == dead_marks_text():
				show_help()

	update_rules_label()
	update_music()


func start_tutorial() -> void:
	bubble.clear_text()
	tutorial = Tutorial.new()
	board_view.session = tutorial.session
	last_snapshot = tutorial.session.snapshot()
	last_conflicts = Rules.conflicts(tutorial.session.board, tutorial.session.level).size()
	last_dead_marks = []
	last_lines = []
	tutorial.session.changed.connect(_refresh)
	hud.set_tutorial_mode(true)
	var step = tutorial.current_step()
	if not step.is_empty():
		board_view.highlight_cells = step["highlight"]
		bubble.show_panel(TutorialSteps.apply_language(language, tutorial.step_index))
	else:
		board_view.highlight_cells = []
		bubble.clear_text()
	board_view.queue_redraw()
	_refresh()


func end_tutorial() -> void:
	if tutorial != null:
		tutorial.session.changed.disconnect(_refresh)
	tutorial = null
	board_view.session = session
	last_snapshot = session.snapshot()
	last_conflicts = Rules.conflicts(session.board, session.level).size()
	var marks = Rules.dead_marks(session.board, session.level)
	last_dead_marks = marks
	last_lines = Rules.filled_lines(session.board, session.level)
	board_view.highlight_cells = []
	hud.set_tutorial_mode(false)
	bubble.clear_text()
	show_help()
	_refresh()
	tutorial_finished.emit()


func open_rules() -> void:
	if rules_panel != null:
		rules_panel.open(language)


func rules_is_open() -> bool:
	return rules_panel != null and rules_panel.visible


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
			bubble.show_panel(TutorialSteps.apply_language(language, tutorial.step_index))
		else:
			board_view.highlight_cells = []
			bubble.clear_text()
		board_view.queue_redraw()


# 操作の説明を消さずに出しておく（ヒント・クリアの表示・チュートリアルの間はそちらを出す）。
# 文は今の language から作るので、言語を切り替えたあとはその言語の説明になる。
func show_help() -> void:
	if is_tutorial():
		return
	bubble.show_text(help_text(), 0.0)


func help_text() -> String:
	if not is_tutorial() and session != null and session.board != null and session.level != null:
		var dead = Rules.dead_marks(session.board, session.level)
		if not dead.is_empty():
			return dead_marks_text()
	
	if language == "ja":
		return "タップ: ×   ダブルタップ: 宇宙人\nスワイプ: ×"
	else:
		return HELP_TEXT


func dead_marks_text() -> String:
	if language == "ja":
		return "× だけの色・行・列があるよ\n× をタップして消してね"
	else:
		return "A LINE OR COLOR HAS ONLY X\nTAP AN X TO REMOVE IT"


func size_up_text() -> String:
	if session == null or session.level == null or session.level_index == 0:
		return ""
	
	var prev_level = session.levels[session.level_index - 1]
	if prev_level.width < session.level.width:
		if language == "ja":
			return "この面からはマスが %d×%d になるよ。がんばって！" % [session.level.width, session.level.width]
		else:
			return "THE BOARD IS %dx%d FROM HERE. GOOD LUCK!" % [session.level.width, session.level.width]
	return ""


func size_up_tile_text() -> String:
	if size_up_text() == "":
		return ""
	var w = session.level.width
	if language == "ja":
		return "この面からはマスが %d×%d になるよ。\nがんばって！" % [w, w]
	else:
		return "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!" % [w, w]


func is_last_level() -> bool:
	return session.level_index == session.levels.size() - 1


func cleared_text() -> String:
	if is_last_level():
		if language == "ja":
			return "全部の面をクリア！  タップでタイトルへ"
		return ALL_CLEARED_TEXT
	if language == "ja":
		return "クリア！  タップで次の面"
	return CLEARED_TEXT


func go_back() -> void:
	if rules_is_open():
		rules_panel.close()
	else:
		on_title_requested()


func on_title_requested() -> void:
	save_progress()
	title_requested.emit()

func _process(delta: float) -> void:
	if session == null or is_tutorial() or rules_is_open():
		return
	tick_size_up(delta)
	session.tick(delta)
	hud.set_time(session.elapsed)

func tick_size_up(delta: float) -> void:
	if size_up_wait > 0.0:
		size_up_wait -= delta
		if size_up_wait <= 0.0:
			size_up_wait = 0.0
			size_up_age = 0.0
			bubble.show_size_up(size_up_tile_text(), board_view.position + board_view.board_rect().get_center())
			sound.play_sfx("line")
			sound.vibrate(60, 0.6)
	elif bubble.tile_mode and bubble.text == size_up_tile_text():
		size_up_age += delta

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

func hint_text(en_text: String) -> String:
	if language != "ja":
		return en_text
	var dict = {
		"THIS CELL IS MARKED BY MISTAKE. TAP TO REMOVE THE X.": "このマスの × はまちがい。タップで × を消す。",
		"THIS ALIEN IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT.": "この宇宙人の場所はまちがい。ダブルタップで消す。",
		"AN ALIEN GOES HERE. DOUBLE TAP TO PLACE IT.": "ここに宇宙人が入る。ダブルタップで置く。"
	}
	if dict.has(en_text):
		return dict[en_text]
	return en_text

func update_music() -> void:
	if session != null and session.level != null:
		var size = max(session.level.width, session.level.height)
		sound.play_music(Sound.bgm_for_size(size))


func rock_ng(x: int, y: int) -> bool:
	if is_tutorial():
		return false
	if session == null:
		return false
	if session.is_radar(x, y) or session.is_asteroid(x, y):
		sound.play_sfx("wrong")
		sound.vibrate(250, 0.3)
		return true
	return false

func update_rules_label() -> void:
	if rules_label == null:
		return
	var level = null
	if is_tutorial():
		level = tutorial.session.level
	else:
		if session != null:
			level = session.level
	rules_label.apply_level(level)
