extends Node2D

const STAR_COLORS = [
	Color(1, 1, 1),
	Color(1.0, 0.80, 0.90),
	Color(1.0, 0.95, 0.70),
	Color(0.75, 0.95, 1.0)
]

var sky_size := Vector2(1080, 1920)
var avoid_rects: Array = []

static func layout_offsets(w: float, h: float) -> Vector2:
	var extra = max(h - 1920.0, 0.0)
	var extra_x = max(w - 1080.0, 0.0)
	return Vector2(extra_x / 2.0, extra / 2.0)

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

func planet_positions(rects: Array) -> Array:
	var base_planets = planet_list()
	var result = []
	
	for p in base_planets:
		var pos = p["pos"]
		var radius = p["radius"]
		var color = p["color"]
		
		var is_yellow = (color == Color(1.0, 0.90, 0.50))
		var is_pink = (color == Color(1.0, 0.70, 0.80))
		
		var new_pos = pos
		var new_radius = radius
		var valid = true
		
		if is_yellow:
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
					new_pos = Vector2(pos.x, (min_y + max_y_pos) / 2.0)
				else:
					var available_height = band_bottom - band_top
					if available_height > 10:
						new_radius = available_height / 2.0
						new_pos = Vector2(pos.x, band_top + new_radius)
					else:
						valid = false
			else:
				valid = false
				
		elif is_pink:
			var draw_extent = 130.0
			var check_rect = Rect2(new_pos.x - draw_extent, new_pos.y - draw_extent, draw_extent * 2, draw_extent * 2)
			
			var intersects = false
			for r in rects:
				if check_rect.intersects(r):
					intersects = true
					break
			
			if intersects:
				var found = false
				# Try moving up first (to the top area above the board)
				for dy in range(0, 1500, 20):
					var test_pos = Vector2(pos.x, pos.y - dy)
					var test_rect = Rect2(test_pos.x - draw_extent, test_pos.y - draw_extent, draw_extent * 2, draw_extent * 2)
					var hit = false
					for r in rects:
						if test_rect.intersects(r):
							hit = true
							break
					if not hit and test_pos.y - draw_extent >= 0:
						new_pos = test_pos
						found = true
						break
				
				if not found:
					# Try moving down (to the bottom area below the rules label)
					for dy in range(0, 1500, 20):
						var test_pos = Vector2(pos.x, pos.y + dy)
						var test_rect = Rect2(test_pos.x - draw_extent, test_pos.y - draw_extent, draw_extent * 2, draw_extent * 2)
						var hit = false
						for r in rects:
							if test_rect.intersects(r):
								hit = true
								break
						if not hit and test_pos.y + draw_extent <= sky_size.y:
							new_pos = test_pos
							found = true
							break
				
				if not found:
					# Try moving left/right if vertical fails? 
					# Or just keep original if we can't find a spot, but test requires it to exist and be valid.
					# If we absolutely cannot find a non-intersecting spot, we might have to shrink or skip.
					# But the prompt says "place in non-intersecting position". 
					# Let's try a more robust search: scan the whole sky for a valid spot for the pink planet.
					var step = 50.0
					for x in range(0, int(sky_size.x), int(step)):
						for y in range(0, int(sky_size.y), int(step)):
							var test_pos = Vector2(float(x), float(y))
							var test_rect = Rect2(test_pos.x - draw_extent, test_pos.y - draw_extent, draw_extent * 2, draw_extent * 2)
							var hit = false
							for r in rects:
								if test_rect.intersects(r):
									hit = true
									break
							if not hit:
								new_pos = test_pos
								found = true
								break
						if found: break
				
				if not found:
					valid = false

		if valid:
			result.append({
				"pos": new_pos,
				"radius": new_radius,
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
			var ring_color = Color(1.0, 0.92, 0.96, 0.8)
			var ring_width = 130.0
			var ring_height = 30.0
			var ring_points = []
			for i in range(32):
				var angle = (float(i) / 32.0) * TAU
				var x = pos.x + cos(angle) * ring_width
				var y = pos.y + sin(angle) * ring_height
				ring_points.append(Vector2(x, y))
			for i in range(32):
				draw_line(ring_points[i], ring_points[(i + 1) % 32], ring_color, 8.0)
			
			var eye_color = Color(0.25, 0.15, 0.30)
			var cheek_color = Color(1.0, 0.50, 0.65, 0.8)
			
			draw_circle(pos + Vector2(-26, -10), 8.0, eye_color)
			draw_circle(pos + Vector2(26, -10), 8.0, eye_color)
			
			draw_circle(pos + Vector2(-44, 14), 10.0, cheek_color)
			draw_circle(pos + Vector2(44, 14), 10.0, cheek_color)
			
			var mouth_center = pos + Vector2(0, 12)
			var mouth_radius = 14.0
			draw_arc(mouth_center, mouth_radius, 0.0, PI, 16, eye_color, 5.0)
			
		elif color == Color(1.0, 0.90, 0.50):
			var pattern_color = Color(0.95, 0.80, 0.40)
			draw_circle(pos + Vector2(-14, -10), 10.0, pattern_color)
			draw_circle(pos + Vector2(16, 12), 7.0, pattern_color)
