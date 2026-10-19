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


static func load_default_levels() -> Array:
	var out: Array = []
	for d in LevelPack.level_dicts():
		var lv = Level.new()
		if lv.parse(d):
			out.append(lv)
	return out


# 1 回タップ: 空→×、×→消す。駒の上では何もしない。
func tap(x: int, y: int) -> bool:
	if status != "playing" or board == null:
		return false
	if is_asteroid(x, y):
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
	if is_asteroid(x, y):
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
		if not is_asteroid(c.x, c.y):
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


func _start_level(index: int, regenerate: bool = true) -> void:
	level_index = index
	if levels.is_empty():
		level = null
	else:
		var original_level = levels[index]
		if uses_default_levels and index >= 10 and regenerate and original_level != null:
			var dict = LevelMaker.make_level(original_level.width, original_level.width, rng.randi())
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
	status = "playing"
	current_hint = {}
	changed.emit()


func _commit(did_change: bool) -> bool:
	if not did_change:
		return false
	moves += 1
	if Rules.is_solved(board, level):
		status = "cleared"
		score += CLEAR_SCORE
		hints = mini(hints + 1, DEFAULT_HINTS)
	changed.emit()
	return true


func save_dict() -> Dictionary:
	return {
		"level_index": level_index,
		"score": score,
		"hints": hints
	}


func restore_dict(data: Dictionary) -> void:
	var li = int(data.get("level_index", 0))
	if li < 0 or li >= levels.size():
		li = 0
	score = int(data.get("score", 0))
	hints = int(data.get("hints", DEFAULT_HINTS))
	_start_level(li)
