extends Node2D

const STAR_COLORS = [
	Color(1, 1, 1),
	Color(1.0, 0.80, 0.90),
	Color(1.0, 0.95, 0.70),
	Color(0.75, 0.95, 1.0)
]

func sky_colors() -> Array:
	return [Color(0.22, 0.14, 0.40), Color(0.08, 0.10, 0.24)]

func star_list(seed_value: int, count: int) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var stars = []
	for i in range(count):
		var x = rng.randf_range(0.0, 1080.0)
		var y = rng.randf_range(0.0, 1920.0)
		var size = rng.randi_range(3, 7)
		stars.append({
			"pos": Vector2(x, y),
			"size": size,
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

func _draw() -> void:
	var colors = sky_colors()
	var top_color = colors[0]
	var bottom_color = colors[1]
	
	# Draw sky gradient using draw_polygon with 4 corners
	var points = [
		Vector2(0, 0),
		Vector2(1080, 0),
		Vector2(1080, 1920),
		Vector2(0, 1920)
	]
	var point_colors = [top_color, top_color, bottom_color, bottom_color]
	draw_polygon(points, point_colors)
	
	# Draw stars
	var stars = star_list(20261011, 60)
	for s in stars:
		var pos = s["pos"]
		var size = s["size"]
		var color = s["color"]
		
		# Vertical thin rectangle
		var v_width = size * 0.4
		var v_height = size * 3.0
		var v_points = [
			pos + Vector2(-v_width / 2.0, -v_height / 2.0),
			pos + Vector2(v_width / 2.0, -v_height / 2.0),
			pos + Vector2(v_width / 2.0, v_height / 2.0),
			pos + Vector2(-v_width / 2.0, v_height / 2.0)
		]
		draw_polygon(v_points, [color, color, color, color])
		
		# Horizontal thin rectangle
		var h_width = size * 3.0
		var h_height = size * 0.4
		var h_points = [
			pos + Vector2(-h_width / 2.0, -h_height / 2.0),
			pos + Vector2(h_width / 2.0, -h_height / 2.0),
			pos + Vector2(h_width / 2.0, h_height / 2.0),
			pos + Vector2(-h_width / 2.0, h_height / 2.0)
		]
		draw_polygon(h_points, [color, color, color, color])
		
		# Center circle
		draw_circle(pos, size * 0.6, color)
	
	# Draw planets
	var planets = planet_list()
	for p in planets:
		var pos = p["pos"]
		var radius = p["radius"]
		var color = p["color"]
		
		# Planet body
		draw_circle(pos, radius, color)
		
		# Specific decorations for the first planet (pink one with ring and face)
		if p == planets[0]:
			# Ring: Ellipse outline
			var ring_color = Color(1.0, 0.92, 0.96, 0.8)
			var ring_width = 130.0
			var ring_height = 30.0
			var ring_points = []
			for i in range(32):
				var angle = (float(i) / 32.0) * TAU
				var x = pos.x + cos(angle) * ring_width
				var y = pos.y + sin(angle) * ring_height
				ring_points.append(Vector2(x, y))
			# Draw closed loop for the ellipse
			for i in range(32):
				draw_line(ring_points[i], ring_points[(i + 1) % 32], ring_color, 8.0)
			
			# Face details
			var eye_color = Color(0.25, 0.15, 0.30)
			var cheek_color = Color(1.0, 0.50, 0.65, 0.8)
			
			# Eyes
			draw_circle(pos + Vector2(-26, -10), 8.0, eye_color)
			draw_circle(pos + Vector2(26, -10), 8.0, eye_color)
			
			# Cheeks
			draw_circle(pos + Vector2(-44, 14), 10.0, cheek_color)
			draw_circle(pos + Vector2(44, 14), 10.0, cheek_color)
			
			# Mouth (Arc)
			var mouth_center = pos + Vector2(0, 12)
			var mouth_radius = 14.0
			draw_arc(mouth_center, mouth_radius, 0.0, PI, 16, eye_color, 5.0)
			
		elif p == planets[1]:
			# Yellow planet patterns
			var pattern_color = Color(0.95, 0.80, 0.40)
			draw_circle(pos + Vector2(-14, -10), 10.0, pattern_color)
			draw_circle(pos + Vector2(16, 12), 7.0, pattern_color)
