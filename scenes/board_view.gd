# 画面の層（SPEC.md 3 節）: 盤を描く。区域の色、白い ×、駒（宇宙人の絵）、岩（小惑星）。
# 状態は変えない。session を読んで描くだけ。
extends Node2D

const Rules = preload("res://core/rules.gd")

# 1080 x 1920 の画面での盤の置き場所（正方形）
const AREA := Rect2(40, 480, 1000, 1000)
# 区域の色（パステル調）
const REGION_COLORS := [
	Color(1.0, 0.72, 0.45),   # 橙
	Color(0.55, 0.78, 1.0),   # 青
	Color(0.58, 0.88, 0.55),  # 緑
	Color(0.80, 0.65, 0.95),  # 紫
	Color(1.0, 0.62, 0.66),   # 赤
	Color(1.0, 0.90, 0.50),   # 黄
	Color(0.55, 0.90, 0.88),  # 水色
	Color(0.80, 0.80, 0.82),  # 灰
]
const MARK_COLOR := Color(0.25, 0.22, 0.40)
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

# --- CR-1022 New Functions ---

func tile_rect(x: int, y: int) -> Rect2:
	var r := cell_rect(x, y)
	var inset := r.size.x * 0.04
	return r.grow(-inset)

func corner_radius() -> float:
	var g := geometry()
	var cs: float = g["cell"]
	if cs <= 0.0:
		return 0.0
	return cs * 0.18

func board_bg_rect() -> Rect2:
	return board_rect().grow(14.0)

func mark_color() -> Color:
	return MARK_COLOR

func mark_thickness() -> float:
	return 12.0

# -----------------------------

func _draw_round_rect(rect: Rect2, radius: float, color: Color, filled: bool = true, width: float = 1.0) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	if r <= 0.0:
		if filled:
			draw_rect(rect, color, true)
		else:
			draw_rect(rect, color, false, width)
		return

	var points := PackedVector2Array()
	var pos := rect.position
	var size := rect.size
	
	# Top Left Corner
	points.append(Vector2(pos.x + r, pos.y))
	points.append(Vector2(pos.x + size.x - r, pos.y))
	# Top Right Corner
	points.append(Vector2(pos.x + size.x, pos.y + r))
	points.append(Vector2(pos.x + size.x, pos.y + size.y - r))
	# Bottom Right Corner
	points.append(Vector2(pos.x + size.x - r, pos.y + size.y))
	points.append(Vector2(pos.x + r, pos.y + size.y))
	# Bottom Left Corner
	points.append(Vector2(pos.x, pos.y + size.y - r))
	points.append(Vector2(pos.x, pos.y + r))
	
	if filled:
		draw_polygon(points, PackedColorArray([color]))
	else:
		# Draw outline by drawing lines between points and closing the loop
		for i in range(points.size()):
			var p1 := points[i]
			var p2 := points[(i + 1) % points.size()]
			draw_line(p1, p2, color, width)


func _draw() -> void:
	var gs := grid_size()
	if gs == Vector2i.ZERO:
		return
	
	# 1. Draw Board Background (CR-1022)
	var bg_rect := board_bg_rect()
	_draw_round_rect(bg_rect, 36.0, Color(0.20, 0.18, 0.32), true)

	var snap: Dictionary = session.board.snapshot()
	var radius := corner_radius()
	
	for y in range(gs.y):
		var row: String = snap["rows"][y]
		for x in range(gs.x):
			var r := cell_rect(x, y)
			var t_r := tile_rect(x, y)
			var region_col := region_color(session.level.region_at(x, y))
			
			# 2. Draw Tile Shadow (CR-1022)
			var shadow_offset := r.size.x * 0.03
			var shadow_rect := t_r
			shadow_rect.position.y += shadow_offset
			# "0.75 times darker" interpreted as multiplying brightness by 0.75
			var shadow_col := region_col * Color(0.75, 0.75, 0.75)
			_draw_round_rect(shadow_rect, radius, shadow_col, true)

			# 3. Draw Tile Base (CR-1022)
			_draw_round_rect(t_r, radius, region_col, true)
			
			# 4. Draw Tile Highlight (CR-1022)
			var highlight_height := t_r.size.y * 0.35
			var highlight_width_inset := t_r.size.x * 0.08
			var highlight_rect := Rect2(
				t_r.position + Vector2(highlight_width_inset, 0),
				Vector2(t_r.size.x - 2 * highlight_width_inset, highlight_height)
			)
			_draw_round_rect(highlight_rect, radius, Color(1, 1, 1, 0.22), true)

			# Draw Content (Rock or Piece/Mark)
			if is_rock(x, y):
				_draw_rock(r)
			else:
				match row[x]:
					"x":
						_draw_mark(r)
					"P":
						_draw_piece(r, piece_fill(x, y))

	# 5. Draw Highlight/Darkening (CR-1022)
	if highlight_cells.size() > 0:
		for y in range(gs.y):
			for x in range(gs.x):
				var cell := Vector2i(x, y)
				if not (cell in highlight_cells):
					var t_r := tile_rect(x, y)
					_draw_round_rect(t_r, radius, Color(0.10, 0.08, 0.20, 0.65), true)

	# 6. Draw Hint (CR-1022)
	if hint_cell.x >= 0 and hint_cell.y >= 0:
		var t_r := tile_rect(hint_cell.x, hint_cell.y)
		_draw_round_rect(t_r, radius, Color(1.0, 0.9, 0.2), false, 12.0)


func _draw_mark(r: Rect2) -> void:
	var m := r.size.x * 0.28
	var a := r.position + Vector2(m, m)
	var b := r.end - Vector2(m, m)
	var thickness := mark_thickness()
	var color := mark_color()
	
	# Draw lines
	draw_line(a, b, color, thickness)
	draw_line(Vector2(a.x, b.y), Vector2(b.x, a.y), color, thickness)
	
	# Draw rounded caps (circles at ends)
	var cap_radius := thickness * 0.5
	draw_circle(a, cap_radius, color)
	draw_circle(b, cap_radius, color)
	draw_circle(Vector2(a.x, b.y), cap_radius, color)
	draw_circle(Vector2(b.x, a.y), cap_radius, color)


func _draw_piece(r: Rect2, fill: Color) -> void:
	# CR-1022: Removed white background rect behind piece
	
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
