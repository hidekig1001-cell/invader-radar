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

# CR-1130: 数字のあるマスに描く × の色
const MARK_ON_NUMBER_COLOR := Color(1, 1, 1, 0.6)
# 駒（黒）を置いた数字のマスの数字の色（紺だと駒に埋もれて読めない）
const PIECE_NUMBER_COLOR := Color(1, 1, 1)

# CR-1142: 駒の画像
const PIECE_TEXTURES := {
	"cyan": preload("res://assets/piece_cyan.png"),
	"green": preload("res://assets/piece_green.png"),
	"navy": preload("res://assets/piece_navy.png"),
	"orange": preload("res://assets/piece_orange.png"),
	"pink": preload("res://assets/piece_pink.png"),
	"purple": preload("res://assets/piece_purple.png"),
	"conflict": preload("res://assets/piece_conflict.png")
}
const ROCK_TEXTURE := preload("res://assets/rock.png")
# REGION_COLORS と同じ順で、区域番号に対応する駒の色の名前
const REGION_PIECE_COLORS := ["navy", "orange", "pink", "green", "cyan", "purple", "pink", "navy"]

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
const PIECE_POSE_TEXTURES := {
	"cyan": [preload("res://assets/piece_cyan.png"), preload("res://assets/piece_cyan_2.png"), preload("res://assets/piece_cyan_3.png"), preload("res://assets/piece_cyan_4.png")],
	"green": [preload("res://assets/piece_green.png"), preload("res://assets/piece_green_2.png"), preload("res://assets/piece_green_3.png"), preload("res://assets/piece_green_4.png")],
	"navy": [preload("res://assets/piece_navy.png"), preload("res://assets/piece_navy_2.png"), preload("res://assets/piece_navy_3.png"), preload("res://assets/piece_navy_4.png")],
	"orange": [preload("res://assets/piece_orange.png"), preload("res://assets/piece_orange_2.png"), preload("res://assets/piece_orange_3.png"), preload("res://assets/piece_orange_4.png")],
	"pink": [preload("res://assets/piece_pink.png"), preload("res://assets/piece_pink_2.png"), preload("res://assets/piece_pink_3.png"), preload("res://assets/piece_pink_4.png")],
	"purple": [preload("res://assets/piece_purple.png"), preload("res://assets/piece_purple_2.png"), preload("res://assets/piece_purple_3.png"), preload("res://assets/piece_purple_4.png")]
}
var piece_poses: Dictionary = {}
var pose_rng := RandomNumberGenerator.new()
const PIECE_POP_TIME := 0.15
var piece_pop_start: Dictionary = {}
var pop_clock: float = 0.0


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

# CR-1023: 角の丸い四角の輪郭の点の並びを返す。
# 左上の角から時計回り（左上 → 右上 → 右下 → 左下）。
# 各角は segments + 1 個の点で作る。
func round_rect_points(rect: Rect2, radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var pos := rect.position
	var size := rect.size
	
	# Clamp radius
	var r := minf(radius, minf(size.x, size.y) * 0.5)
	if r <= 0.0:
		return points

	# Helper to add arc points for a corner
	# center: Vector2, start_angle: float, end_angle: float (radians)
	# We iterate from start to end in steps of segments+1 points.
	# Note: In Godot 2D, Y is down. Angles are typically measured from positive X axis counter-clockwise in math, 
	# but visually "clockwise" on screen means angle increases if we consider standard math angles? 
	# Let's stick to the spec's explicit coordinate definitions to avoid confusion.
	
	# Top Left Corner: Center (pos.x + r, pos.y + r)
	# Start: (pos.x, pos.y + r) -> Vector from center: (-r, 0). Angle PI.
	# End: (pos.x + r, pos.y) -> Vector from center: (0, -r). Angle -PI/2 or 3PI/2.
	# Spec says "clockwise". Visually from left edge to top edge is clockwise.
	# In screen coords (Y down), moving from (-r, 0) to (0, -r) via the arc closest to origin (0,0) relative to center?
	# The arc is in the quadrant x < cx, y < cy.
	# Angle of start vector (-1, 0) is PI.
	# Angle of end vector (0, -1) is -PI/2 (or 3PI/2).
	# To go clockwise visually (from left to top), we decrease angle? 
	# Let's check the midpoint test: P[2] for segments=4.
	# Indices 0,1,2,3,4. Index 2 is middle.
	# Expected: Vector2(10 - 10*cos(PI/4), 10 - 10*sin(PI/4)).
	# Center (10,10). Vector (-7.07, -7.07). Angle is 5PI/4 or -3PI/4? 
	# cos(5PI/4) = -0.707, sin(5PI/4) = -0.707.
	# So angle is 5PI/4 (225 degrees).
	# Start angle PI (180 deg). End angle 3PI/2 (270 deg) or -PI/2.
	# If we go from PI to 3PI/2, that's increasing angle. In standard math (Y up), this is CCW.
	# But Y is down. Increasing angle in standard math (CCW) looks like CW on screen?
	# Let's verify: 
	# Angle 0: (1,0) -> Right.
	# Angle PI/2: (0,1) -> Down (because Y is down).
	# So increasing angle goes Right -> Down -> Left -> Up. This is Clockwise on screen.
	# So we want to increase angle from Start to End.
	# Top Left: Start (-r, 0) is Angle PI. End (0, -r) is Angle 3PI/2 (or -PI/2).
	# To go clockwise visually (Left edge to Top edge), we go from Angle PI to Angle 3PI/2?
	# Wait. Left edge point is (0, r) relative to center? No, pos.x is left. Center is pos.x+r.
	# Point (pos.x, pos.y+r) is (-r, 0) relative to center. Angle PI.
	# Point (pos.x+r, pos.y) is (0, -r) relative to center. Angle 3PI/2 (or -PI/2).
	# If we increase angle from PI to 3PI/2, we pass through 5PI/4 (which is (-0.7, -0.7)).
	# This matches the midpoint test!
	# So: Start Angle = PI, End Angle = 3PI/2. Step = (End - Start) / segments.
	
	var tl_center := Vector2(pos.x + r, pos.y + r)
	var tl_start_angle := PI
	var tl_end_angle := 1.5 * PI # 3PI/2
	
	# Top Right Corner: Center (pos.x + size.x - r, pos.y + r)
	# Start: (pos.x + size.x - r, pos.y) -> Vector (-r? No. x is right edge minus r. Center is right edge minus r. So x diff is 0? 
	# Wait. Top Right corner arc starts at top edge right end?
	# Spec: "Top Right is from (x + width - radius, y) to (x + width, y + radius)"
	# Start point: (pos.x + size.x - r, pos.y). Relative to center (pos.x + size.x - r, pos.y + r): Vector (0, -r). Angle 3PI/2.
	# End point: (pos.x + size.x, pos.y + r). Relative to center: Vector (r, 0). Angle 0 (or 2PI).
	# We need to go from 3PI/2 to 2PI (increasing angle).
	var tr_center := Vector2(pos.x + size.x - r, pos.y + r)
	var tr_start_angle := 1.5 * PI
	var tr_end_angle := 2.0 * PI
	
	# Bottom Right Corner: Center (pos.x + size.x - r, pos.y + size.y - r)
	# Spec: "Bottom Right is from (x + width, y + height - radius) to (x + width - radius, y + height)"
	# Start point: (pos.x + size.x, pos.y + size.y - r). Relative to center: Vector (r, 0). Angle 0.
	# End point: (pos.x + size.x - r, pos.y + size.y). Relative to center: Vector (0, r). Angle PI/2.
	# Go from 0 to PI/2.
	var br_center := Vector2(pos.x + size.x - r, pos.y + size.y - r)
	var br_start_angle := 0.0
	var br_end_angle := 0.5 * PI
	
	# Bottom Left Corner: Center (pos.x + r, pos.y + size.y - r)
	# Spec: "Bottom Left is from (x + radius, y + height) to (x, y + height - radius)"
	# Start point: (pos.x + r, pos.y + size.y). Relative to center: Vector (0, r). Angle PI/2.
	# End point: (pos.x, pos.y + size.y - r). Relative to center: Vector (-r, 0). Angle PI.
	# Go from PI/2 to PI.
	var bl_center := Vector2(pos.x + r, pos.y + size.y - r)
	var bl_start_angle := 0.5 * PI
	var bl_end_angle := PI
	
	var step_tl := (tl_end_angle - tl_start_angle) / float(segments)
	var step_tr := (tr_end_angle - tr_start_angle) / float(segments)
	var step_br := (br_end_angle - br_start_angle) / float(segments)
	var step_bl := (bl_end_angle - bl_start_angle) / float(segments)
	
	# Add Top Left Arc
	for i in range(segments + 1):
		var angle := tl_start_angle + step_tl * float(i)
		var p := tl_center + Vector2(cos(angle), sin(angle)) * r
		points.append(p)
		
	# Add Top Right Arc (skip first point as it's same as last of TL? No, TL ends at (pos.x+r, pos.y). TR starts at (pos.x+size.x-r, pos.y). They are different unless width=2r.
	# The spec implies continuous outline. 
	# TL End: (pos.x + r, pos.y).
	# TR Start: (pos.x + size.x - r, pos.y).
	# These are connected by a straight line along the top edge? 
	# Wait, the function returns "points of the outline".
	# If I just append arcs, I miss the straight edges between corners.
	# However, looking at the test:
	# P[4] is (10, 0) [TL End].
	# P[5] is (90, 0) [TR Start].
	# There is NO point in between for the straight line segment from (10,0) to (90,0).
	# The polygon drawing will connect P[4] and P[5] with a straight line.
	# So we just need to append the arcs. The straight lines are implicit between the end of one arc and start of next.
	
	# Add Top Right Arc
	for i in range(segments + 1):
		var angle := tr_start_angle + step_tr * float(i)
		var p := tr_center + Vector2(cos(angle), sin(angle)) * r
		points.append(p)
		
	# Add Bottom Right Arc
	for i in range(segments + 1):
		var angle := br_start_angle + step_br * float(i)
		var p := br_center + Vector2(cos(angle), sin(angle)) * r
		points.append(p)
		
	# Add Bottom Left Arc
	for i in range(segments + 1):
		var angle := bl_start_angle + step_bl * float(i)
		var p := bl_center + Vector2(cos(angle), sin(angle)) * r
		points.append(p)
		
	return points


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

	var points := round_rect_points(rect, radius, 8)
	
	if points.is_empty():
		if filled:
			draw_rect(rect, color, true)
		else:
			draw_rect(rect, color, false, width)
		return

	if filled:
		draw_polygon(points, PackedColorArray([color]))
	else:
		# Draw outline by drawing lines between points and closing the loop
		for i in range(points.size()):
			var p1 := points[i]
			var p2 := points[(i + 1) % points.size()]
			draw_line(p1, p2, color, width)

# --- CR-1048 New Functions ---

func radar_font_size() -> float:
	if session == null or session.level == null:
		return 0.0
	var g := geometry()
	var cs: float = g["cell"]
	if cs <= 0.0:
		return 0.0
	return cs / 3.0

func radar_label_center(x: int, y: int) -> Vector2:
	return cell_rect(x, y).get_center()

func radar_text_color(x: int, y: int) -> Color:
	if session == null or session.level == null:
		return MARK_COLOR
	
	var limit := -1
	for r in session.level.radar:
		if r is Array and r.size() >= 3:
			if int(r[0]) == x and int(r[1]) == y:
				limit = int(r[2])
				break
		elif r is Vector3i:
			if r.x == x and r.y == y:
				limit = r.z
				break
				
	if limit < 0:
		return MARK_COLOR
		
	var count := Rules.radar_count(session.board.pieces(), x, y)
	if count > limit:
		return Color.RED
	
	# CR-1137: Radar text is always white unless exceeded (red).
	return Color(1, 1, 1)


# 駒を描くマスかどうか（_draw で駒を描く所と同じ判定: 岩ではなく、snapshot の行の文字が "P"）。
func has_piece_at(x: int, y: int) -> bool:
	if session == null or session.board == null or session.level == null:
		return false
	if is_rock(x, y):
		return false
	var rows: Array = session.board.snapshot()["rows"]
	if y < 0 or y >= rows.size():
		return false
	var row: String = rows[y]
	if x < 0 or x >= row.length():
		return false
	return row[x] == "P"

# -----------------------------

# CR-1130: 指定したマスに radar の数字があるかどうかを返す。
func has_radar(x: int, y: int) -> bool:
	if session == null or session.level == null:
		return false
	
	for r in session.level.radar:
		if r is Array:
			if r.size() >= 2 and int(r[0]) == x and int(r[1]) == y:
				return true
		elif r is Vector3i:
			if r.x == x and r.y == y:
				return true
				
	return false

# CR-1130: 指定したマスに描く × の色を返す。
# CR-1137: Always return mark_color() to unify X color.
func mark_color_at(x: int, y: int) -> Color:
	if session != null and session.level != null:
		var dead := Rules.dead_marks(session.board, session.level)
		if Vector2i(x, y) in dead:
			return Color.RED
	return mark_color()


# CR-1137: 数字の縁取りの色を返す。
func radar_outline_color() -> Color:
	return Color(0.12, 0.10, 0.22)

# CR-1137: 数字の縁取りの太さを返す。
func radar_outline_size() -> int:
	return 8

# --- CR-1142 New Functions ---

func piece_color_name(x: int, y: int) -> String:
	if session == null or session.board == null or session.level == null:
		return "navy"
	var conflicts = Rules.conflicts(session.board, session.level)
	if Vector2i(x, y) in conflicts:
		return "conflict"
	var region = session.level.region_at(x, y)
	var idx = posmod(region, REGION_PIECE_COLORS.size())
	return REGION_PIECE_COLORS[idx]

func piece_texture(x: int, y: int) -> Texture2D:
	var color_name := piece_color_name(x, y)
	if color_name == "conflict":
		return PIECE_TEXTURES["conflict"]
	return PIECE_POSE_TEXTURES[color_name][piece_pose(x, y)]

func rock_texture() -> Texture2D:
	return ROCK_TEXTURE

func piece_image_rect(r: Rect2) -> Rect2:
	return r.grow(-r.size.x * 0.06)

# -----------------------------


func _draw() -> void:
	var gs := grid_size()
	if gs == Vector2i.ZERO:
		return
	
	forget_empty_poses()

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
				draw_texture_rect(rock_texture(), piece_image_rect(r), false)
			else:
				# CR-1171: Draw rock image under numbers if radar exists
				if rock_image_at(x, y):
					draw_texture_rect(rock_texture(), piece_image_rect(r), false)
				
				match row[x]:
					"x":
						_draw_mark(r, mark_color_at(x, y))
					"P":
						var pop_scale := piece_pop_scale(x, y, pop_clock)
						var target_rect := scaled_rect(piece_image_rect(r), pop_scale)
						draw_texture_rect(piece_texture(x, y), target_rect, false)

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

	# 7. Draw Radar Labels (CR-1048)
	if session != null and session.level != null:
		var font_size := radar_font_size()
		if font_size > 0.0:
			for r in session.level.radar:
				var rx := -1
				var ry := -1
				var rn := -1
				
				if r is Array and r.size() >= 3:
					rx = int(r[0])
					ry = int(r[1])
					rn = int(r[2])
				elif r is Vector3i:
					rx = r.x
					ry = r.y
					rn = r.z
				
				if rx >= 0 and ry >= 0 and rn >= 0:
					var center := radar_label_center(rx, ry)
					var color := radar_text_color(rx, ry)
					var text := str(rn)
					# Calculate position to center the text
					# draw_string expects baseline position. 
					# To center vertically, we need to account for font ascent/descent.
					# A simple approximation for centering: y = center.y + font_size * 0.35 (approx baseline offset)
					# And x = center.x - text_width / 2
					var font := ThemeDB.fallback_font
					var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
					var draw_pos := Vector2(center.x - text_width * 0.5, center.y + font_size * 0.35)
					
					# CR-1137: Draw outline before text
					draw_string_outline(font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, radar_outline_size(), radar_outline_color())
					draw_string(font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_mark(r: Rect2, color: Color) -> void:
	var m := r.size.x * 0.28
	var a := r.position + Vector2(m, m)
	var b := r.end - Vector2(m, m)
	var thickness := mark_thickness()
	
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


func piece_pose(x: int, y: int) -> int:
	if not has_piece_at(x, y):
		return 0
	var key := Vector2i(x, y)
	if not piece_poses.has(key):
		piece_poses[key] = pose_rng.randi_range(0, 3)
		piece_pop_start[key] = pop_clock
	return piece_poses[key]


func forget_empty_poses() -> void:
	var keys_to_remove: Array = []
	for key in piece_poses.keys():
		if not has_piece_at(key.x, key.y):
			keys_to_remove.append(key)
	for key in keys_to_remove:
		piece_poses.erase(key)
		piece_pop_start.erase(key)


func piece_pop_scale(x: int, y: int, now: float) -> float:
	var key := Vector2i(x, y)
	if not piece_pop_start.has(key):
		return 1.0
	var start_time: float = piece_pop_start[key]
	var t := (now - start_time) / PIECE_POP_TIME
	if t <= 0.0 or t >= 1.0:
		return 1.0
	return 1.0 + 0.2 * sin(PI * t)


func scaled_rect(rect: Rect2, s: float) -> Rect2:
	var center := rect.get_center()
	var new_size := rect.size * s
	return Rect2(center - new_size * 0.5, new_size)


func _process(delta: float) -> void:
	pop_clock += delta
	var needs_redraw := false
	for key in piece_pop_start.keys():
		if pop_clock - piece_pop_start[key] < PIECE_POP_TIME + delta:
			needs_redraw = true
			break
	if needs_redraw:
		queue_redraw()


func rock_image_at(x: int, y: int) -> bool:
	return is_rock(x, y) or has_radar(x, y)
