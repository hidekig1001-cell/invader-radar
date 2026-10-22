extends Node2D

const STAR_COLORS = [
	Color(1, 1, 1),
	Color(1.0, 0.80, 0.90),
	Color(1.0, 0.95, 0.70),
	Color(0.75, 0.95, 1.0)
]

const SAFE_TOP_MARGIN := 80.0

var sky_size := Vector2(1080, 1920)
var avoid_rects: Array = []
var pink_min_y: float = 0.0

static func layout_offsets(w: float, h: float) -> Vector2:
	var extra = max(h - 1920.0, 0.0)
	var extra_x = max(w - 1080.0, 0.0)
	return Vector2(extra_x / 2.0, extra / 2.0)

static func safe_layout_offsets(w: float, h: float, safe_top: float) -> Vector2:
	var base = layout_offsets(w, h)
	var extra = max(h - 1920.0, 0.0)
	var y = max(base.y, safe_top - SAFE_TOP_MARGIN)
	return Vector2(base.x, min(y, extra))

static func safe_top_for_layout(safe_top_px: float, window_h: float, layout_h: float) -> float:
	if window_h <= 0:
		return 0.0
	return safe_top_px * layout_h / window_h

static func screen_size_for_layout(visible: Vector2, display_name: String) -> Vector2:
	if display_name == "headless":
		return Vector2(1080, 1920)
	return visible

func sky_colors() -> Array:
	return [Color(0.22, 0.14, 0.40), Color(0.08, 0.10, 0.24)]

func star_list(seed_value: int, count: int) -> Array:
	return star_list_for(Vector2(1080, 1920), seed_value, count)

func star_list_for(size: Vector2, seed_value: int, count: int) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var stars = []
	for i in range(count):
		var x = rng.randf_range(0.0, size.x)
		var y = rng.randf_range(0.0, size.y)
		var size_val = rng.randi_range(3, 7)
		stars.append({
			"pos": Vector2(x, y),
			"size": size_val,
			"color": STAR_COLORS[i % 4]
		})
	return stars

func planet_list() -> Array:
	return [
		{
			"pos": Vector2(120, 1620),
			"radius": 80.0,
			"color": Color(1.0, 0.70, 0.80)
		},
		{
			"pos": Vector2(110, 1840),
			"radius": 50.0,
			"color": Color(1.0, 0.90, 0.50)
		},
		{
			"pos": Vector2(60, 60),
			"radius": 26.0,
			"color": Color(0.60, 0.95, 0.80)
		}
	]

static func pink_draw_extent(radius: float) -> float:
	return radius * 130.0 / 80.0

static func pink_scale(radius: float) -> float:
	return radius / 80.0

static func pink_ring_size(radius: float) -> Vector2:
	var e = pink_draw_extent(radius)
	var h = 30.0 * radius / 80.0
	return Vector2(e, h)

func guard_planets() -> Array:
	var guards = []
	for p in planet_list():
		var color = p["color"]
		if color == Color(1.0, 0.90, 0.50): # Yellow
			var pos = p["pos"]
			var radius = p["radius"]
			var max_y = 0.0
			for r in avoid_rects:
				if r.end.y > max_y:
					max_y = r.end.y
			
			var band_top = max_y
			var band_bottom = sky_size.y
			
			if band_bottom > band_top:
				var min_y = band_top + radius
				var max_y_pos = band_bottom - radius
				
				if min_y <= max_y_pos:
					pos = Vector2(pos.x, (min_y + max_y_pos) / 2.0)
				else:
					var available_height = band_bottom - band_top
					if available_height > 10:
						radius = available_height / 2.0
						pos = Vector2(pos.x, band_top + radius)
					else:
						continue
			else:
				continue
				
			guards.append({"pos": pos, "radius": radius})
			
		elif color == Color(0.60, 0.95, 0.80): # Green
			guards.append({"pos": p["pos"], "radius": p["radius"]})
			
	return guards

func pink_spot_ok(pos: Vector2, radius: float, rects: Array) -> bool:
	var e = pink_draw_extent(radius)
	var check_rect = Rect2(pos.x - e, pos.y - e, 2 * e, 2 * e)
	var sky_rect = Rect2(Vector2.ZERO, sky_size)
	
	if not sky_rect.encloses(check_rect):
		return false
		
	for r in rects:
		if check_rect.intersects(r):
			return false
			
	var guards = guard_planets()
	for g in guards:
		var dist = pos.distance_to(g["pos"])
		if dist <= radius + g["radius"]:
			return false
			
	return true

func pink_placement(rects: Array) -> Dictionary:
	var radii = []
	for r in range(80, 4, -5):
		radii.append(float(r))
		
	for radius in radii:
		var e = pink_draw_extent(radius)
		
		var max_y = int(sky_size.y)
		var max_x = int(sky_size.x)
		
		for y in range(int(pink_min_y), max_y + 1, 5):
			for x in range(0, max_x + 1, 5):
				var pos = Vector2(float(x), float(y))
				if pink_spot_ok(pos, radius, rects):
					return {"pos": pos, "radius": radius}
					
	return {}

func planet_positions(rects: Array) -> Array:
	var result = []
	
	for p in planet_list():
		var color = p["color"]
		var pos = p["pos"]
		var radius = p["radius"]
		
		if color == Color(1.0, 0.90, 0.50): # Yellow
			var max_y = 0.0
			for r in rects:
				if r.end.y > max_y:
					max_y = r.end.y
			
			var band_top = max_y
			var band_bottom = sky_size.y
			
			if band_bottom > band_top:
				var min_y = band_top + radius
				var max_y_pos = band_bottom - radius
				
				if min_y <= max_y_pos:
					pos = Vector2(pos.x, (min_y + max_y_pos) / 2.0)
				else:
					var available_height = band_bottom - band_top
					if available_height > 10:
						radius = available_height / 2.0
						pos = Vector2(pos.x, band_top + radius)
					else:
						continue
			else:
				continue
				
			result.append({"pos": pos, "radius": radius, "color": color})
			
		elif color == Color(0.60, 0.95, 0.80): # Green
			result.append({"pos": pos, "radius": radius, "color": color})
			
		elif color == Color(1.0, 0.70, 0.80): # Pink
			var placement = pink_placement(rects)
			if not placement.is_empty():
				result.append({
					"pos": placement["pos"],
					"radius": placement["radius"],
					"color": color
				})
				
	return result

func _draw() -> void:
	var colors = sky_colors()
	var top_color = colors[0]
	var bottom_color = colors[1]
	
	var points = [
		Vector2(0, 0),
		Vector2(sky_size.x, 0),
		Vector2(sky_size.x, sky_size.y),
		Vector2(0, sky_size.y)
	]
	var point_colors = [top_color, top_color, bottom_color, bottom_color]
	draw_polygon(points, point_colors)
	
	var stars = star_list_for(sky_size, 20261011, 60)
	for s in stars:
		var pos = s["pos"]
		var size = s["size"]
		var color = s["color"]
		
		var v_width = size * 0.4
		var v_height = size * 3.0
		var v_points = [
			pos + Vector2(-v_width / 2.0, -v_height / 2.0),
			pos + Vector2(v_width / 2.0, -v_height / 2.0),
			pos + Vector2(v_width / 2.0, v_height / 2.0),
			pos + Vector2(-v_width / 2.0, v_height / 2.0)
		]
		draw_polygon(v_points, [color, color, color, color])
		
		var h_width = size * 3.0
		var h_height = size * 0.4
		var h_points = [
			pos + Vector2(-h_width / 2.0, -h_height / 2.0),
			pos + Vector2(h_width / 2.0, -h_height / 2.0),
			pos + Vector2(h_width / 2.0, h_height / 2.0),
			pos + Vector2(-h_width / 2.0, h_height / 2.0)
		]
		draw_polygon(h_points, [color, color, color, color])
		
		draw_circle(pos, size * 0.6, color)
	
	var planets = planet_positions(avoid_rects)
	for p in planets:
		var pos = p["pos"]
		var radius = p["radius"]
		var color = p["color"]
		
		draw_circle(pos, radius, color)
		
		if color == Color(1.0, 0.70, 0.80):
			var scale = pink_scale(radius)
			var ring_size = pink_ring_size(radius)
			
			var ring_color = Color(1.0, 0.92, 0.96, 0.8)
			var ring_width = ring_size.x
			var ring_height = ring_size.y
			
			var ring_points = []
			for i in range(32):
				var angle = (float(i) / 32.0) * TAU
				var x = pos.x + cos(angle) * ring_width
				var y = pos.y + sin(angle) * ring_height
				ring_points.append(Vector2(x, y))
			for i in range(32):
				draw_line(ring_points[i], ring_points[(i + 1) % 32], ring_color, 8.0 * scale)
			
			var eye_color = Color(0.25, 0.15, 0.30)
			var cheek_color = Color(1.0, 0.50, 0.65, 0.8)
			
			# Eyes
			draw_circle(pos + Vector2(-26 * scale, -10 * scale), 8.0 * scale, eye_color)
			draw_circle(pos + Vector2(26 * scale, -10 * scale), 8.0 * scale, eye_color)
			
			# Cheeks
			draw_circle(pos + Vector2(-44 * scale, 14 * scale), 10.0 * scale, cheek_color)
			draw_circle(pos + Vector2(44 * scale, 14 * scale), 10.0 * scale, cheek_color)
			
			# Mouth
			var mouth_center = pos + Vector2(0, 12 * scale)
			var mouth_radius = 14.0 * scale
			draw_arc(mouth_center, mouth_radius, 0.0, PI, 16, eye_color, 5.0 * scale)
			
		elif color == Color(1.0, 0.90, 0.50):
			var pattern_color = Color(0.95, 0.80, 0.40)
			draw_circle(pos + Vector2(-14, -10), 10.0, pattern_color)
			draw_circle(pos + Vector2(16, 12), 7.0, pattern_color)
