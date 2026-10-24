extends GutTest

const BubbleScript = preload("res://scenes/message_bubble.gd")
const MainScene = preload("res://scenes/main.tscn")
const Hud = preload("res://scenes/hud.gd")
const TitleScreen = preload("res://scenes/title_screen.gd")
const RulesPanel = preload("res://scenes/rules_panel.gd")
const BoardView = preload("res://scenes/board_view.gd")
const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const Save = preload("res://game/session_save.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _make_bubble():
	var b = BubbleScript.new()
	add_child_autofree(b)
	await wait_frames(1)
	return b


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_pixel_1023_bubble_is_orange_with_white_text() -> void:
	var b = await _make_bubble()
	var box = b.normal_box
	assert_true(box is StyleBoxFlat)
	assert_eq(box.bg_color, Color8(255, 140, 50))
	assert_eq(box.bg_color.a, 1.0)
	assert_eq(box.border_color, Color8(214, 96, 20))
	assert_eq(box.border_width_left, 4)
	assert_eq(box.corner_radius_top_left, 24)
	assert_eq(b.get_theme_color("font_color"), Color.WHITE)
	assert_eq(b.get_theme_color("font_outline_color"), Color8(150, 60, 0))
	assert_eq(b.get_theme_constant("outline_size"), 6)

	b.show_panel("STEP")
	assert_eq(b.get_theme_color("font_color"), BubbleScript.TILE_FONT_COLOR)
	b.clear_text()
	assert_eq(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_color("font_color"), Color.WHITE)
	assert_eq(b.get_theme_constant("outline_size"), 6)

	b.show_tile("CLEAR", Vector2(540, 900))
	assert_eq(b.get_theme_color("font_color"), BubbleScript.TILE_FONT_COLOR)
	b.clear_text()
	assert_eq(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_color("font_color"), Color.WHITE)


## CHECK: 2
func test_pixel_1023_fit_font_size() -> void:
	var b = await _make_bubble()
	var short_text := "A"
	var long_text := "THIS IS A MUCH LONGER SENTENCE THAT HAS TO WRAP OVER SEVERAL LINES IN THE BUBBLE"
	var fs_short: int = b.fit_font_size(short_text, BubbleScript.BOX.size, 52, 24)
	var fs_long: int = b.fit_font_size(long_text, BubbleScript.BOX.size, 52, 24)
	assert_eq(fs_short, 52)
	assert_lt(fs_long, fs_short)
	assert_true(fs_long >= 24)

	var sb = b.get_theme_stylebox("normal")
	var pad_x: float = sb.get_content_margin(SIDE_LEFT) + sb.get_content_margin(SIDE_RIGHT)
	var pad_y: float = sb.get_content_margin(SIDE_TOP) + sb.get_content_margin(SIDE_BOTTOM)
	var h: float = b.text_height(long_text, BubbleScript.BOX.size.x - pad_x, fs_long)
	assert_true(h <= BubbleScript.BOX.size.y - pad_y)
	assert_true(b.text_height(long_text, BubbleScript.BOX.size.x - pad_x, fs_long + 2) > BubbleScript.BOX.size.y - pad_y)

	b.show_text(long_text, 0.0)
	assert_eq(b.get_theme_font_size("font_size"), fs_long)
	assert_eq(b.size, BubbleScript.BOX.size)
	b.show_text(short_text, 0.0)
	assert_eq(b.get_theme_font_size("font_size"), 52)

	# 今ある文（操作の説明・チュートリアルの段）で枠の大きさが変わらない
	for t in ["TAP: X   DOUBLE TAP: PIECE\nSWIPE: X", "タップ: ×   ダブルタップ: 駒\nスワイプ: ×"]:
		b.show_text(t, 0.0)
		assert_eq(b.size, BubbleScript.BOX.size)
	for lang in ["en", "ja"]:
		for i in range(TutorialSteps.steps().size()):
			var step_text: String = TutorialSteps.apply_language(lang, i)
			b.show_panel(step_text)
			assert_eq(b.size, BubbleScript.PANEL_BOX.size, lang + " step " + str(i))
			b.clear_text()


## CHECK: 3
func test_pixel_1023_help_text_stays_and_returns_after_hint() -> void:
	var m = await _start_main()
	assert_eq(m.bubble.text, m.help_text())
	for i in range(50):
		m.bubble._process(0.1)
		m._process(0.1)
	assert_true(m.bubble.visible)
	assert_eq(m.bubble.text, m.help_text())

	m.hud.hint_button.pressed.emit()
	await wait_frames(1)
	assert_eq(m.bubble.text, "A PIECE GOES HERE. DOUBLE TAP TO PLACE IT.")

	m.session.tap(3, 3)
	await wait_frames(1)
	assert_true(m.bubble.visible)
	assert_eq(m.bubble.text, m.help_text())


## CHECK: 3
func test_pixel_1023_help_text_after_next_level_and_ja() -> void:
	var m = await _start_main()
	m.session.solve_now()
	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, m.cleared_text())
	m.session.next_level()
	assert_false(m.bubble.tile_mode)
	assert_true(m.bubble.visible)
	assert_eq(m.bubble.text, m.help_text())

	var n = MainScene.instantiate()
	n.language = "ja"
	add_child_autofree(n)
	await wait_frames(2)
	assert_eq(n.bubble.text, "タップ: ×   ダブルタップ: 駒\nスワイプ: ×")


## CHECK: 4
func test_pixel_1023_sound_labels_show_next_action() -> void:
	var path = "user://test_pixel_1023_settings.json"
	Save.write_json(path, {"muted": false})

	var h = Hud.new()
	h.settings_path = path
	add_child_autofree(h)
	h.set_language("en")
	assert_eq(h.sound_label(), "SOUND OFF")
	h.set_language("ja")
	assert_eq(h.sound_label(), "音 OFF")

	var ts = TitleScreen.new()
	ts.settings_path = path
	add_child_autofree(ts)
	assert_eq(ts.sound_label(), "SOUND OFF")
	ts.select_language("ja")
	assert_eq(ts.sound_label(), "音 OFF")

	var rp = RulesPanel.new()
	rp.settings_path = path
	add_child_autofree(rp)
	rp.open("en")
	assert_eq(rp.sound_label(), "SOUND OFF")
	rp.open("ja")
	assert_eq(rp.sound_label(), "音 OFF")

	Save.write_json(path, {"muted": true})
	h.set_language("en")
	assert_eq(h.sound_label(), "SOUND ON")
	h.set_language("ja")
	assert_eq(h.sound_label(), "音 ON")
	ts.muted = true
	ts.select_language("en")
	assert_eq(ts.sound_label(), "SOUND ON")
	ts.select_language("ja")
	assert_eq(ts.sound_label(), "音 ON")
	rp.open("en")
	assert_eq(rp.sound_label(), "SOUND ON")
	rp.open("ja")
	assert_eq(rp.sound_label(), "音 ON")
	Save.write_json(path, {"muted": false})
	AudioServer.set_bus_mute(0, false)


func _radar_session(pieces: Array):
	var level = Level.new()
	assert_true(level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"radar": [[0, 0, 2]],
		"asteroids": [],
		"regions": [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
	}))
	var s = SessionScript.new([level])
	for p in pieces:
		s.board.apply("place", p.x, p.y)
	return s


## CHECK: 5
func test_pixel_1023_radar_text_white_on_piece() -> void:
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = _radar_session([Vector2i(0, 0)])
	assert_eq(bv.radar_text_color(0, 0), Color(1, 1, 1))

	bv.session = _radar_session([Vector2i(1, 0)])
	assert_eq(bv.radar_text_color(0, 0), Color(1, 1, 1))

	bv.session = _radar_session([Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	assert_eq(bv.radar_text_color(0, 0), Color.RED)

	var s = _radar_session([])
	s.board.apply("mark", 0, 0)
	bv.session = s
	assert_true(bv.mark_color_at(0, 0).is_equal_approx(Color(0.25, 0.22, 0.40)))
	assert_eq(bv.radar_text_color(0, 0), Color(1, 1, 1))
