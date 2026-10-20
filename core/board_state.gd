# 規則の層（SPEC.md 2 節）: 遊び手の印の盤。各マスは EMPTY・MARK（×）・PIECE（駒）のどれか。
# 「1 回目のタップで ×、もう一度で消す」などの操作の読み替えは game/session.gd の仕事。ここは action を当てるだけ。
extends RefCounted

const Grid = preload("res://core/grid.gd")

const EMPTY := 0
const MARK := 1
const PIECE := 2
# action 名 → 当てた後のマスの状態
const ACTIONS := {"mark": MARK, "place": PIECE, "clear": EMPTY}
const SYMBOLS := {EMPTY: ".", MARK: "x", PIECE: "P"}

var width: int = 0
var height: int = 0
var _grid = null
var _history: Array = []  # {"x", "y", "prev"} の並び（undo 用。状態が変わった手だけ）


func _init(w: int = 0, h: int = 0) -> void:
	width = w
	height = h
	_grid = Grid.new(w, h, EMPTY)


func state_at(x: int, y: int) -> int:
	return _grid.get_cell(x, y, -1)


# 盤の外・知らない action は ERR_INVALID_PARAMETER。すでにその状態なら OK（何も変えず、履歴にも積まない）。
func apply(action: String, x: int, y: int) -> int:
	if not ACTIONS.has(action) or not _grid.in_bounds(x, y):
		return ERR_INVALID_PARAMETER
	var prev: int = _grid.get_cell(x, y)
	var next: int = ACTIONS[action]
	if prev != next:
		_history.append({"x": x, "y": y, "prev": prev})
		_grid.set_cell(x, y, next)
	return OK


# 直前の変更を 1 つ戻す。戻すものがなければ false。
func undo() -> bool:
	if _history.is_empty():
		return false
	var h: Dictionary = _history.pop_back()
	_grid.set_cell(h["x"], h["y"], h["prev"])
	return true


func history_size() -> int:
	return _history.size()


func clear_history() -> void:
	_history.clear()


func pieces() -> Array:
	return _cells_with(PIECE)


func marks() -> Array:
	return _cells_with(MARK)


func snapshot() -> Dictionary:
	var rows: Array = []
	for y in range(height):
		var s := ""
		for x in range(width):
			s += SYMBOLS.get(_grid.get_cell(x, y), "?")
		rows.append(s)
	return {"width": width, "height": height, "rows": rows,
		"marks": marks().size(), "pieces": pieces().size()}


func restore_rows(rows: Array) -> int:
	if rows.size() != height:
		return ERR_INVALID_PARAMETER
	
	var symbol_to_state := {}
	for state in SYMBOLS.keys():
		symbol_to_state[SYMBOLS[state]] = state

	for y in range(height):
		var row = rows[y]
		if not (row is String):
			return ERR_INVALID_PARAMETER
		if row.length() != width:
			return ERR_INVALID_PARAMETER
		
		for x in range(width):
			var char = row[x]
			if not symbol_to_state.has(char):
				return ERR_INVALID_PARAMETER
	
	for y in range(height):
		var row = rows[y]
		for x in range(width):
			var char = row[x]
			var state = symbol_to_state[char]
			_grid.set_cell(x, y, state)
	
	_history.clear()
	return OK


func _cells_with(state: int) -> Array:
	var out: Array = []
	for y in range(height):
		for x in range(width):
			if _grid.get_cell(x, y) == state:
				out.append(Vector2i(x, y))
	return out
