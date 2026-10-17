extends RefCounted

static func make_box(tex_path: String, drop: int) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load(tex_path)
	sb.texture_margin_left = 32
	sb.texture_margin_right = 32
	sb.texture_margin_top = 44
	sb.texture_margin_bottom = 40
	if drop == 4:
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		sb.content_margin_top = 8
		sb.content_margin_bottom = 0
	else:
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
	return sb

static func apply_to(btn: Button) -> void:
	var normal_tex := "res://assets/buttons/button_normal.png"
	var pressed_tex := "res://assets/buttons/button_pressed.png"
	var disabled_tex := "res://assets/buttons/button_disabled.png"

	btn.add_theme_stylebox_override("normal", make_box(normal_tex, 0))
	btn.add_theme_stylebox_override("hover", make_box(normal_tex, 0))
	btn.add_theme_stylebox_override("focus", make_box(normal_tex, 0))
	btn.add_theme_stylebox_override("pressed", make_box(pressed_tex, 4))
	btn.add_theme_stylebox_override("disabled", make_box(disabled_tex, 0))

	var font_color := Color8(74, 50, 10)
	var disabled_color := Color8(78, 74, 96)

	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_color_override("font_hover_color", font_color)
	btn.add_theme_color_override("font_pressed_color", font_color)
	btn.add_theme_color_override("font_disabled_color", disabled_color)
