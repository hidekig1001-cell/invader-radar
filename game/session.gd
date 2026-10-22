# 面の層（SPEC.md 2 節）: 面の並び・今の面・手数・スコア・ヒントの残り・状態。
# 操作（tap・double_tap・swipe）を board_state の action に読み替えて当て、解けたかを rules に聞く。
extends RefCounted

signal changed

const BoardState = preload("res://core/board_state.gd")
const Rules = preload("res://core/rules.gd")
const Level = preload("res://game/level.gd")
const LevelPack = preload("res://game/level_pack.gd")
const Hint = preload("res://core/hint.gd")
const LevelMaker = preload("res://game/level_maker.gd")
const Solver = preload("res://core/solver.gd")
const LevelPrefetch = preload("res://game/level_prefetch.gd")

const LEVEL_PATHS := [
	"res://data/levels/level_001.json",
	"res://data/levels/level_002.json",
	"res://data/levels/level_003.json",
]
const DEFAULT_HINTS := 3
const CLEAR_SCORE := 100

var levels: Array = []
var level_index: int = 0
var level = null
var board = null
var moves: int = 0
var score: int = 0
var hints: int = DEFAULT_HINTS
var status: String = "playing"  # "playing" | "cleared"
var current_hint: Dictionary = {}
var rng: RandomNumberGenerator
var uses_default_levels: bool = false
var given: Vector2i = Vector2i(-1, -1)
var elapsed: float = 0.0
var max_cleared: int = 0
var clear_records: Array = []
var prefetch = LevelPrefetch.new()


# level_list（Level の並び）を渡せばそれを使う。空なら data/levels の面を読む。
func _init(level_list: Array = []) -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	if level_list.is_empty():
		uses_default_levels = true
		levels = load_default_levels()
	else:
		uses_default_levels = false
		levels = level_list
	_start_level(0)


static func placeholder_regions(w: int) -> Array:
	var out: Array = []
	for y in range(w):
		var row: Array = []
		for x in range(w):
			row.append(y)
		out.append(row)
	return out


static func load_default_levels() -> Array:
	var out: Array = []
	for d in LevelPack.fixed_level_dicts():
		var lv = Level.new()
		if lv.parse(d):
			out.append(lv)
	for spec in LevelPack.GENERATED_SPECS:
		var id = spec[0]
		var w = spec[1]
		var regions = placeholder_regions(w)
		var d = {
			"id": id,
			"width": w,
			"height": w,
			"target": w,
			"regions": regions
		}
		var lv = Level.new()
		if lv.parse(d):
			out.append(lv)
	return out


# 1 回タップ: 空→×、×→消す。駒の上では何もしない。
func tap(x: int, y: int) -> bool:
	if status != "playing" or board == null:
		return false
	if is_asteroid(x, y) or is_given(x, y):
		return false
	match board.state_at(x, y):
		BoardState.EMPTY:
			return _commit(board.apply("mark", x, y) == OK)
		BoardState.MARK:
			return _commit(board.apply("clear", x, y) == OK)
	return false


# ダブルタップ: 空・×→駒を置く、駒→取り除く。
func double_tap(x: int, y: int) -> bool:
	if status != "playing" or board == null:
		return false
	if is_asteroid(x, y) or is_given(x, y):
		return false
	match board.state_at(x, y):
		BoardState.EMPTY, BoardState.MARK:
			return _commit(board.apply("place", x, y) == OK)
		BoardState.PIECE:
			return _commit(board.apply("clear", x, y) == OK)
	return false


# スワイプ: なぞった空のマスに ×（×や駒のマスはそのまま）。全体で 1 手。
func swipe(cells: Array) -> bool:
	if status != "playing" or board == null:
		return false
	var filtered_cells: Array = []
	for c in cells:
		if not is_asteroid(c.x, c.y) and not is_given(c.x, c.y):
			filtered_cells.append(c)
	if filtered_cells.is_empty():
		return false
	var changed_any := false
	for c in filtered_cells:
		if board.state_at(c.x, c.y) == BoardState.EMPTY and board.apply("mark", c.x, c.y) == OK:
			changed_any = true
	return _commit(changed_any)


# 直前の変更を 1 つ戻す（手数は変えない）。
func undo() -> bool:
	if status != "playing" or board == null or not board.undo():
		return false
	changed.emit()
	return true


# ヒントの残りを 1 つ減らす。ヒントの中身は CR で足す（土台では残りの数だけ）。
func use_hint() -> bool:
	if status != "playing" or hints <= 0:
		return false
	hints -= 1
	changed.emit()
	return true


# 次の面へ。最後の面の次は最初の面に戻る。スコアとヒントの残りは引き継ぐ。
func next_level() -> bool:
	if levels.is_empty():
		return false
	_start_level((level_index + 1) % levels.size())
	return true


func restart_level() -> void:
	_start_level(level_index, false)


func snapshot() -> Dictionary:
	return {"level": level.id if level != null else 0, "moves": moves, "score": score,
		"hints": hints, "status": status, "board": board.snapshot() if board != null else {}}


# ヒントを求める。出せたら残りを 1 減らして true
func request_hint() -> bool:
	if status != "playing" or hints <= 0:
		return false
	var hint_data = Hint.next_hint(board, level)
	if hint_data.is_empty():
		return false
	hints -= 1
	current_hint = hint_data
	changed.emit()
	return true


# 今のヒントのとおりに盤を直す。直したら true
func apply_hint() -> bool:
	if current_hint.is_empty():
		return false
	var cell: Vector2i = current_hint["cell"]
	var kind: String = current_hint["kind"]
	var x: int = cell.x
	var y: int = cell.y
	var did_change := false
	if kind == "wrong_mark" or kind == "wrong_piece":
		did_change = board.apply("clear", x, y) == OK
	elif kind == "next_piece":
		did_change = board.apply("place", x, y) == OK
	current_hint = {}
	return _commit(did_change)


func is_asteroid(x: int, y: int) -> bool:
	if level == null:
		return false
	var target_pos = Vector2i(x, y)
	for a in level.asteroids:
		if a == target_pos:
			return true
	return false


func is_given(x: int, y: int) -> bool:
	return given == Vector2i(x, y)


func _start_level(index: int, regenerate: bool = true) -> void:
	level_index = index
	var pre_solution: Array = []
	if levels.is_empty():
		level = null
	else:
		var original_level = levels[index]
		if uses_default_levels and index >= 10 and regenerate and original_level != null:
			var spec = LevelPack.GENERATED_SPECS[index - 10]
			var pre = prefetch.take(index)
			var dict: Dictionary
			if not pre.is_empty():
				dict = pre["level"]
				pre_solution = pre["solution"]
			else:
				dict = LevelMaker.make_level(original_level.width, original_level.width, rng.randi(), spec[3], spec[4])
			
			dict["id"] = original_level.id
			var new_level = Level.new()
			if new_level.parse(dict):
				level = new_level
				levels[index] = new_level
			else:
				level = original_level
		else:
			level = original_level
	
	board = BoardState.new(level.width, level.height) if level != null else null
	moves = 0
	elapsed = 0.0
	status = "playing"
	current_hint = {}
	given = Vector2i(-1, -1)
	
	if level != null and level.width >= 6:
		var solutions: Array = []
		if not pre_solution.is_empty():
			solutions = [pre_solution]
		else:
			solutions = Solver.solutions(level, 1)
		
		if not solutions.is_empty():
			var solution: Array = solutions[0]
			var mid_y = level.height / 2
			if mid_y < solution.size():
				given = solution[mid_y]
				board.apply("place", given.x, given.y)
				board.clear_history()
	
	prefetch_next()
	changed.emit()


func _commit(did_change: bool) -> bool:
	if not did_change:
		return false
	moves += 1
	if Rules.is_solved(board, level):
		status = "cleared"
		clear_records.append({"level": level.id, "seconds": elapsed, "moves": moves})
		max_cleared = maxi(max_cleared, level.id)
		score += CLEAR_SCORE
		hints = mini(hints + 1, DEFAULT_HINTS)
	changed.emit()
	return true


func save_dict() -> Dictionary:
	var out := {
		"level_index": level_index,
		"score": score,
		"hints": hints,
		"max_cleared": max_cleared,
		"clears": clear_records.duplicate(true),
		"moves": moves,
		"elapsed": elapsed
	}
	if level != null:
		out["level"] = level.to_dict()
	if board != null:
		out["rows"] = board.snapshot()["rows"]
	return out


func restore_dict(data: Dictionary) -> void:
	var li = int(data.get("level_index", 0))
	if li < 0 or li >= levels.size():
		li = 0
	score = int(data.get("score", 0))
	hints = int(data.get("hints", DEFAULT_HINTS))
	max_cleared = int(data.get("max_cleared", 0))
	var clears = data.get("clears", [])
	clear_records = clears.duplicate(true) if typeof(clears) == TYPE_ARRAY else []
	
	var saved_level = Level.new()
	var use_saved: bool = data.has("level") and typeof(data["level"]) == TYPE_DICTIONARY and levels[li] != null and saved_level.parse(data["level"]) and saved_level.id == levels[li].id
	
	if use_saved:
		levels[li] = saved_level
		_start_level(li, false)
	else:
		_start_level(li)
		
	if use_saved and board != null and data.has("rows") and typeof(data["rows"]) == TYPE_ARRAY:
		if board.restore_rows(data["rows"]) == OK:
			moves = int(data.get("moves", 0))
			elapsed = float(data.get("elapsed", 0.0))
			changed.emit()


func solve_now() -> bool:
	if status != "playing" or board == null or level == null:
		return false
	var solutions = Solver.solutions(level, 1)
	if solutions.is_empty():
		return false
	var solution: Array = solutions[0]
	for y in range(level.height):
		for x in range(level.width):
			if board.state_at(x, y) != BoardState.EMPTY:
				board.apply("clear", x, y)
	for pos in solution:
		board.apply("place", pos.x, pos.y)
	return _commit(true)


func tick(delta: float) -> void:
	if status == "playing" and level != null:
		elapsed += delta


func prefetch_next() -> void:
	if not uses_default_levels or levels.is_empty():
		return
	var next = (level_index + 1) % levels.size()
	if next < 10 or prefetch.pending_index == next:
		return
	var spec = LevelPack.GENERATED_SPECS[next - 10]
	prefetch.start(next, levels[next].width, rng.randi(), spec[3], spec[4])
