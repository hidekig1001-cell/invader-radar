# 面の層（SPEC.md 2 節）: 面の並び・今の面・手数・スコア・ヒントの残り・状態。
# 操作（tap・double_tap・swipe）を board_state の action に読み替えて当て、解けたかを rules に聞く。
extends RefCounted

signal changed

const BoardState = preload("res://core/board_state.gd")
const Rules = preload("res://core/rules.gd")
const Level = preload("res://game/level.gd")

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


# level_list（Level の並び）を渡せばそれを使う。空なら data/levels の面を読む。
func _init(level_list: Array = []) -> void:
	levels = level_list if not level_list.is_empty() else load_default_levels()
	_start_level(0)


static func load_default_levels() -> Array:
	var out: Array = []
	for path in LEVEL_PATHS:
		var lv = Level.new()
		if lv.load_file(path):
			out.append(lv)
	return out


# 1 回タップ: 空→×、×→消す。駒の上では何もしない。
func tap(x: int, y: int) -> bool:
	if status != "playing" or board == null:
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
	var changed_any := false
	for c in cells:
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
	_start_level(level_index)


func snapshot() -> Dictionary:
	return {"level": level.id if level != null else 0, "moves": moves, "score": score,
		"hints": hints, "status": status, "board": board.snapshot() if board != null else {}}


func _start_level(index: int) -> void:
	level_index = index
	level = levels[index] if index < levels.size() else null
	board = BoardState.new(level.width, level.height) if level != null else null
	moves = 0
	status = "playing"
	changed.emit()


func _commit(did_change: bool) -> bool:
	if not did_change:
		return false
	moves += 1
	if Rules.is_solved(board, level):
		status = "cleared"
		score += CLEAR_SCORE
	changed.emit()
	return true
