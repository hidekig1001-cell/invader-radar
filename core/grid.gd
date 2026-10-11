# 規則の層（SPEC.md 2 節）: 盤。マスの値（int）を持つだけで、Node には触れない。
extends RefCounted

var width: int = 0
var height: int = 0
var _cells: Array = []


func _init(w: int = 0, h: int = 0, fill: int = 0) -> void:
	width = maxi(w, 0)
	height = maxi(h, 0)
	_cells = []
	_cells.resize(width * height)
	_cells.fill(fill)


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


# 盤の外は default_value（既定 -1）を返す。
func get_cell(x: int, y: int, default_value: int = -1) -> int:
	if not in_bounds(x, y):
		return default_value
	return _cells[y * width + x]


# 盤の外なら false（何も変えない）。
func set_cell(x: int, y: int, value: int) -> bool:
	if not in_bounds(x, y):
		return false
	_cells[y * width + x] = value
	return true


# 縦・横の 4 マスのうち、盤の中のもの。
func neighbors4(x: int, y: int) -> Array:
	return _around(x, y, [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)])


# 縦・横・斜めの 8 マスのうち、盤の中のもの。
func neighbors8(x: int, y: int) -> Array:
	var offsets: Array = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx != 0 or dy != 0:
				offsets.append(Vector2i(dx, dy))
	return _around(x, y, offsets)


func copy():
	var g = get_script().new(width, height, 0)
	g._cells = _cells.duplicate()
	return g


# テスト用: 1 行を 1 つの文字列にした並び。値 0〜9 は数字 1 文字、それ以外は "?"。
func to_rows() -> Array:
	var rows: Array = []
	for y in range(height):
		var s := ""
		for x in range(width):
			var v: int = _cells[y * width + x]
			s += str(v) if v >= 0 and v <= 9 else "?"
		rows.append(s)
	return rows


# to_rows の逆。数字以外の文字は 0 にする。
func load_rows(rows: Array) -> void:
	height = rows.size()
	width = 0 if rows.is_empty() else String(rows[0]).length()
	_cells = []
	_cells.resize(width * height)
	_cells.fill(0)
	for y in range(height):
		var s := String(rows[y])
		for x in range(mini(width, s.length())):
			_cells[y * width + x] = s.unicode_at(x) - 48 if s[x] >= "0" and s[x] <= "9" else 0


func _around(x: int, y: int, offsets: Array) -> Array:
	var out: Array = []
	for o in offsets:
		var p := Vector2i(x, y) + (o as Vector2i)
		if in_bounds(p.x, p.y):
			out.append(p)
	return out
