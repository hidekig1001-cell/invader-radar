extends Node2D

signal finished

var background: ColorRect = null
var logo: TextureRect = null
var touch_area: Control = null
var timer: Timer = null
var finished_sent = false

func _ready() -> void:
	background = ColorRect.new()
	background.color = Color(0.05, 0.1, 0.2) # 濃い紺
	add_child(background)

	logo = TextureRect.new()
	logo.texture = load("res://assets/autedev_logo.png")
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(logo)

	touch_area = Control.new()
	touch_area.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(touch_area)

	timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_timeout)

	var viewport_size = get_viewport().get_visible_rect().size
	apply_screen_layout(viewport_size)

func apply_screen_layout(size: Vector2) -> void:
	if background != null:
		background.size = size
	
	if touch_area != null:
		touch_area.size = size

	if logo != null:
		var scale_factor = min(1.0, size.x / 1024.0)
		logo.scale = Vector2(scale_factor, scale_factor)
		
		# Calculate center position based on texture size and scale
		var tex_size = logo.texture.get_size() if logo.texture else Vector2.ZERO
		var scaled_size = tex_size * logo.scale
		var center_pos = Vector2(size.x / 2.0, size.y / 2.0)
		
		# TextureRect pivot is top-left by default in Godot 4 unless changed.
		# To center it, we set position such that the scaled rect is centered.
		logo.position = center_pos - (scaled_size / 2.0)

func on_timeout() -> void:
	finish()

func on_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		finish()

func finish() -> void:
	if not finished_sent:
		finished_sent = true
		emit_signal("finished")
