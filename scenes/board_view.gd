# 画面の層（SPEC.md 3 節）: 盤を描く。区域の色、白い ×、駒（仮の四角。あとで宇宙人の絵にする）。
# 状態は変えない。session を読んで描くだけ。
extends Node2D

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
const GRID_LINE := Color(0, 0, 0, 0.55)

var session = null:
	set(value):
		session = value
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
			match row[x]:
				"x":
					_draw_mark(r)
				"P":
					_draw_piece(r)


func _draw_mark(r: Rect2) -> void:
	var m := r.size.x * 0.28
	var a := r.position + Vector2(m, m)
	var b := r.end - Vector2(m, m)
	draw_line(a, b, MARK_COLOR, 10.0)
	draw_line(Vector2(a.x, b.y), Vector2(b.x, a.y), MARK_COLOR, 10.0)


func _draw_piece(r: Rect2) -> void:
	var inner := r.grow(-r.size.x * 0.22)
	draw_rect(inner, PIECE_FILL, true)
	draw_rect(inner, MARK_COLOR, false, 6.0)
