# 面の層（SPEC.md 2 節）: 1 面の情報と、JSON の読み書き。
# JSON: {"id", "width", "height", "regions": 行ごとの区域番号の配列, "asteroids": [[x,y]...], "radar": [[x,y,n]...], "target"}
extends RefCounted

const Grid = preload("res://core/grid.gd")

var id: int = 0
var width: int = 0
var height: int = 0
var regions = null  # Grid: 区域の番号
var asteroids: Array = []  # Vector2i のマス（土台では使わない）
var radar: Array = []  # レーダーの数字を出すマス [x, y, n]
var target: int = 0


# 読めたら true。形が違えば false（このとき中身は変えない）。
func parse(d: Dictionary) -> bool:
	if not (d.has("width") and d.has("height") and d.has("regions") and d.has("target")):
		return false
	var w := int(d["width"])
	var h := int(d["height"])
	var rows = d["regions"]
	if w <= 0 or h <= 0 or not (rows is Array) or rows.size() != h:
		return false
	var g = Grid.new(w, h, 0)
	for y in range(h):
		if not (rows[y] is Array) or rows[y].size() != w:
			return false
		for x in range(w):
			g.set_cell(x, y, int(rows[y][x]))
	var ast = _read_cells(d.get("asteroids", []), w, h)
	var rad = parse_radar(d.get("radar", []), w, h)
	if ast == null or rad == null:
		return false
	id = int(d.get("id", 0))
	width = w
	height = h
	regions = g
	asteroids = ast
	radar = rad
	target = int(d["target"])
	return true


func to_dict() -> Dictionary:
	var rows: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(regions.get_cell(x, y))
		rows.append(row)
	return {"id": id, "width": width, "height": height, "regions": rows,
		"asteroids": _write_cells(asteroids), "radar": write_radar(radar), "target": target}


func to_json() -> String:
	return JSON.stringify(to_dict())


func parse_json(text: String) -> bool:
	var j := JSON.new()
	if j.parse(text) != OK:
		return false
	return j.data is Dictionary and parse(j.data)


func load_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	return parse_json(FileAccess.get_file_as_string(path))


func region_at(x: int, y: int) -> int:
	return regions.get_cell(x, y)


func region_count() -> int:
	var seen := {}
	for y in range(height):
		for x in range(width):
			seen[regions.get_cell(x, y)] = true
	return seen.size()


# 失敗したら null、成功したら Vector2i の並び。
func _read_cells(list, w: int, h: int):
	var out: Array = []
	if not (list is Array):
		return null
	for c in list:
		if not (c is Array) or c.size() != 2:
			return null
		var p := Vector2i(int(c[0]), int(c[1]))
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			return null
		out.append(p)
	return out


func _write_cells(cells: Array) -> Array:
	var out: Array = []
	for p in cells:
		out.append([p.x, p.y])
	return out


# 面の辞書の radar の [x, y, n] の並びを検査して読み、形が違う・盤外のマス・0 未満の n のとき null を返す（成功は [x, y, n] の並び）。
func parse_radar(list, w: int, h: int):
	var out: Array = []
	if not (list is Array):
		return null
	for c in list:
		if not (c is Array) or c.size() != 3:
			return null
		var x := int(c[0])
		var y := int(c[1])
		var n := int(c[2])
		if x < 0 or y < 0 or x >= w or y >= h:
			return null
		if n < 0:
			return null
		out.append([x, y, n])
	return out


# radar の [x, y, n] の並びを to_dict の "radar" の出力（[[x, y, n]]）として複製して返す。
func write_radar(radar: Array) -> Array:
	var out: Array = []
	for c in radar:
		out.append([c[0], c[1], c[2]])
	return out
