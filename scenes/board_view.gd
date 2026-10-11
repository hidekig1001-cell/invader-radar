# 画面の層（SPEC.md 3 節）: 盤を描く。区域の色、白い ×、駒（宇宙人の絵）、岩（小惑星）。
# 状態は変えない。session を読んで描くだけ。
extends Node2D

const Rules = preload("res://core/rules.gd")

# 1080 x 1920 の画面での盤の置き場所（正方形）
const AREA := Rect2(40, 480, 1000, 1000)
# 区域の色（先頭の 4 色は見分けやすい色。大きな盤のための 4 色は後ろに）
const REGION_COLORS := [
	Color(0.93, 0.55, 0.16),  # 橙
	Color(0.20, 0.60, 0.90),  # 青
	Color(0.30, 0.72, 0.35),  # 緑
	Color(0.70, 0.40, 0.80),  # 紫
	Color(0.90, 0.30, 0.35),
	Color(0.95, 0.85, 0.30),
	Color(0.35, 0.80, 0.80),
	Color(0.60, 0.60, 0.60),
]
const MARK_COLOR := Color(1, 1, 1)
const PIECE_FILL := Color(0.08, 0.08, 0.12)
const CONFLICT_FILL := Color(0.90, 0.15, 0.15)
const GRID_LINE := Color(0, 0, 0, 0.55)

# 宇宙人の絵（幅 8・高さ 8）
const ALIEN_ROWS := [
	"....1...",
	"...1....",
	"..1111..",
	".111111.",
	"11122111",
	"11122111",
	".111111.",
	"..1..1.."
]

# 岩の絵（幅 8・高さ 8）
const ROCK_ROWS := [
	"..1111..",
	".111211.",
	"11112111",
	"11211111",
	"11111121",
	"12111111",
	".111121.",
	"..1111.."
]

const ROCK_COLOR := Color(0.55, 0.52, 0.5)
const ROCK_SHADOW_COLOR := Color(0.35, 0.33, 0.32)

var session = null:
	set(value):
		session = value
		queue_redraw()

var hint_cell: Vector2i = Vector2i(-1, -1):
	set(value):
		hint_cell = value
		queue_redraw()

var highlight_cells: Array = []:
	set(value):
		highlight_cells = value
		queue_redraw()


# 盤の大きさ（マス）。session がなければ 0。
func grid_size() -> Vector2i:
	if session == null or session.level == null:
		return Vector2i.ZERO
	return Vector2i(session.level.width, session.level.height)


# input_mapper に渡す盤の位置。
func geometry() -> Dictionary:
	var gs := grid_size()
	var cs := 0.0
	if gs.x > 0 and gs.y > 0:
		cs = minf(AREA.size.x / gs.x, AREA.size.y / gs.y)
	var board_size := Vector2(cs * gs.x, cs * gs.y)
	var origin := AREA.position + (AREA.size - board_size) * 0.5
	return {"origin": origin, "cell": cs, "w": gs.x, "h": gs.y}


func cell_rect(x: int, y: int) -> Rect2:
	var g := geometry()
	var cs: float = g["cell"]
	return Rect2((g["origin"] as Vector2) + Vector2(x * cs, y * cs), Vector2(cs, cs))


# 盤の全体の矩形（盤の外のタッチを除くのに使う）。
func board_rect() -> Rect2:
	var g := geometry()
	var cs: float = g["cell"]
	return Rect2(g["origin"], Vector2(cs * int(g["w"]), cs * int(g["h"])))


func region_color(region: int) -> Color:
	return REGION_COLORS[posmod(region, REGION_COLORS.size())]


func piece_fill(x: int, y: int) -> Color:
	if session == null or session.board == null or session.level == null:
		return PIECE_FILL
	var conflicts = Rules.conflicts(session.board, session.level)
	if Vector2i(x, y) in conflicts:
		return CONFLICT_FILL
	return PIECE_FILL


func alien_rows() -> Array:
	return ALIEN_ROWS


func rock_rows() -> Array:
	return ROCK_ROWS


func is_rock(x: int, y: int) -> bool:
	if session == null or session.level == null:
		return false
	var target := Vector2i(x, y)
	for a in session.level.asteroids:
		if a == target:
			return true
	return false


func alien_pixel_rect(r: Rect2, col: int, row: int) -> Rect2:
	var inner := r.grow(-r.size.x * 0.22)
	var w := inner.size.x / 8.0
	var h := inner.size.y / 8.0
	return Rect2(
		inner.position + Vector2(col * w, row * h),
		Vector2(w, h)
	)


func _draw() -> void:
	var gs := grid_size()
	if gs == Vector2i.ZERO:
		return
	var snap: Dictionary = session.board.snapshot()
	for y in range(gs.y):
		var row: String = snap["rows"][y]
		for x in range(gs.x):
			var r := cell_rect(x, y)
			draw_rect(r, region_color(session.level.region_at(x, y)), true)
			draw_rect(r, GRID_LINE, false, 4.0)
			
			if is_rock(x, y):
				_draw_rock(r)
			else:
				match row[x]:
					"x":
						_draw_mark(r)
					"P":
						_draw_piece(r, piece_fill(x, y))

	if highlight_cells.size() > 0:
		for y in range(gs.y):
			for x in range(gs.x):
				var cell := Vector2i(x, y)
				if not (cell in highlight_cells):
					var r := cell_rect(x, y)
					draw_rect(r, Color(0, 0, 0, 0.6), true)

	if hint_cell.x >= 0 and hint_cell.y >= 0:
		var r := cell_rect(hint_cell.x, hint_cell.y)
		draw_rect(r, Color(1.0, 0.9, 0.2), false, 14.0)


func _draw_mark(r: Rect2) -> void:
	var m := r.size.x * 0.28
	var a := r.position + Vector2(m, m)
	var b := r.end - Vector2(m, m)
	draw_line(a, b, MARK_COLOR, 10.0)
	draw_line(Vector2(a.x, b.y), Vector2(b.x, a.y), MARK_COLOR, 10.0)


func _draw_piece(r: Rect2, fill: Color) -> void:
	var inner := r.grow(-r.size.x * 0.22)
	# 背景の半透明四角（暗い区域でも見えるように）
	draw_rect(inner.grow(4.0), Color(1, 1, 1, 0.25), true)
	
	var rows := alien_rows()
	for row_idx in range(rows.size()):
		var line: String = rows[row_idx]
		for col_idx in range(line.length()):
			var char := line[col_idx]
			if char == "1":
				var rect := alien_pixel_rect(r, col_idx, row_idx)
				draw_rect(rect, fill, true)
			elif char == "2":
				var rect := alien_pixel_rect(r, col_idx, row_idx)
				draw_rect(rect, Color(1, 1, 1), true)


func _draw_rock(r: Rect2) -> void:
	var rows := rock_rows()
	for row_idx in range(rows.size()):
		var line: String = rows[row_idx]
		for col_idx in range(line.length()):
			var char := line[col_idx]
			if char == "1":
				var rect := alien_pixel_rect(r, col_idx, row_idx)
				draw_rect(rect, ROCK_COLOR, true)
			elif char == "2":
				var rect := alien_pixel_rect(r, col_idx, row_idx)
				draw_rect(rect, ROCK_SHADOW_COLOR, true)
