extends Node2D

const DURATION := 1.6
const PARTICLE_COUNT := 40
const GRAVITY := 900.0
const COLORS := [Color(1.0, 0.85, 0.3), Color(1.0, 0.6, 0.75), Color(0.6, 0.85, 1.0), Color(0.7, 1.0, 0.7)]

var active: bool = false
var elapsed: float = 0.0
var particles: Array = []
var rng := RandomNumberGenerator.new()


func play(center: Vector2) -> void:
	active = true
	elapsed = 0.0
	particles.clear()
	rng.seed = 1
	for i in range(PARTICLE_COUNT):
		var angle := rng.randf_range(0.0, TAU)
		var speed := rng.randf_range(300.0, 700.0)
		var vel := Vector2(cos(angle), sin(angle)) * speed - Vector2(0, 300)
		particles.append({
			"pos": center,
			"vel": vel,
			"color": COLORS[i % COLORS.size()],
			"size": rng.randf_range(8.0, 16.0)
		})
	queue_redraw()


func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	if elapsed >= DURATION:
		active = false
		particles.clear()
		queue_redraw()
		return
	for p in particles:
		p["vel"] += Vector2(0, GRAVITY * delta)
		p["pos"] += p["vel"] * delta
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var alpha := clampf(1.0 - elapsed / DURATION, 0.0, 1.0)
	for p in particles:
		var c: Color = p["color"]
		c.a = alpha
		draw_circle(p["pos"], p["size"], c)
