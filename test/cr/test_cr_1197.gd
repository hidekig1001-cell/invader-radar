extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")

const BASE_JA = "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。"
const BASE_EN = "ONE ALIEN PER ROW, COLUMN AND COLOR.\nALIENS MUST NOT TOUCH, EVEN DIAGONALLY."

func _make_level(id: int, w: int, h: int, asteroids: Array, radar: Array) -> Level:
	var l = Level.new()
	l.id = id
	l.width = w
	l.height = h
	l.asteroids = asteroids
	l.radar = radar
	# regions: 行ごとに 0〜(h-1) の区域
	l.regions = []
	for y in range(h):
		var row = []
		for x in range(w):
			row.append(y)
		l.regions.append(row)
	return l

## CHECK: 1
func test_rules_text_static() -> void:
	var RulesLabel = load("res://scenes/rules_label.gd")
	assert_eq(RulesLabel.rules_text("ja", false, false), BASE_JA)
	assert_eq(RulesLabel.rules_text("ja", true, false), BASE_JA + "\n? の岩には宇宙人を置けない。")
	assert_eq(RulesLabel.rules_text("ja", false, true), BASE_JA + "\n数字は、まわりの 8 マスにいる宇宙人の数。")
	assert_eq(RulesLabel.rules_text("ja", true, true), BASE_JA + "\n? の岩には宇宙人を置けない。 数字は、まわりの 8 マスにいる宇宙人の数。")
	
	assert_eq(RulesLabel.rules_text("en", false, false), BASE_EN)
	assert_eq(RulesLabel.rules_text("en", true, false), BASE_EN + "\nNO ALIEN ON A ? ROCK.")
	assert_eq(RulesLabel.rules_text("en", false, true), BASE_EN + "\nA NUMBER = ALIENS IN THE 8 CELLS AROUND IT.")
	assert_eq(RulesLabel.rules_text("en", true, true), BASE_EN + "\nNO ALIEN ON A ? ROCK. A NUMBER = ALIENS IN THE 8 CELLS AROUND IT.")

## CHECK: 2
func test_apply_level_and_language() -> void:
	var RulesLabel = load("res://scenes/rules_label.gd")
	var Level = load("res://game/level.gd")
	
	var la = Level.new()
	la.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]], "asteroids": [[3, 3]], "radar": []})
	var lb = Level.new()
	lb.parse({"id": 2, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]], "asteroids": [], "radar": []})
	
	var label = RulesLabel.new()
	add_child_autofree(label)
	
	label.apply_language("ja")
	assert_eq(label.text, BASE_JA)
	
	label.apply_level(la)
	assert_eq(label.text, BASE_JA + "\n? の岩には宇宙人を置けない。")
	assert_eq(label.get_theme_font_size("font_size"), 24)
	var sb = label.get_theme_stylebox("normal")
	assert_eq(sb.content_margin_top, 6.0)
	assert_eq(sb.content_margin_bottom, 6.0)
	assert_eq(sb.content_margin_left, 32.0)
	
	label.apply_language("en")
	assert_eq(label.text, BASE_EN + "\nNO ALIEN ON A ? ROCK.")
	
	label.apply_level(lb)
	assert_eq(label.text, BASE_EN)
	assert_eq(label.get_theme_font_size("font_size"), 32)
	sb = label.get_theme_stylebox("normal")
	assert_eq(sb.content_margin_top, 16.0)
	assert_eq(sb.content_margin_bottom, 16.0)
	
	label.apply_level(null)
	assert_eq(label.text, BASE_EN)

## CHECK: 3
func test_main_update_rules_label() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]], "asteroids": [], "radar": []})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]], "asteroids": [], "radar": [[4, 4, 0]]})
	
	var m = MainScene.instantiate()
	m.language = "ja"
	m.session = SessionScript.new([l1, l2, l3])
	add_child_autofree(m)
	await wait_frames(2)
	
	assert_eq(m.rules_label.text, BASE_JA + "\n? の岩には宇宙人を置けない。 数字は、まわりの 8 マスにいる宇宙人の数。")
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 24)
	
	await wait_frames(1)
	assert_true(m.rules_label.get_combined_minimum_size().y <= 128.0)
	assert_true(m.rules_label.get_combined_minimum_size().x <= 972.0)
	assert_eq(m.rules_label.position, Vector2(54, 1732))
	assert_eq(m.rules_label.size, Vector2(972, 128))
	assert_false(m.hud.solve_button.get_global_rect().intersects(m.rules_label.get_global_rect()))
	assert_false(m.hud.hint_button.get_global_rect().intersects(m.rules_label.get_global_rect()))
	
	m.session.next_level()
	assert_eq(m.rules_label.text, BASE_JA)
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 32)
	
	m.session.next_level()
	assert_eq(m.rules_label.text, BASE_JA + "\n数字は、まわりの 8 マスにいる宇宙人の数。")
	
	m.session.restart_level()
	assert_eq(m.rules_label.text, BASE_JA + "\n数字は、まわりの 8 マスにいる宇宙人の数。")
	await wait_frames(1)
	assert_eq(m.rules_label.size, Vector2(972, 128))

## CHECK: 4
func test_tutorial_rules_label() -> void:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]})
	
	var m = MainScene.instantiate()
	m.language = "ja"
	m.session = SessionScript.new([l1])
	add_child_autofree(m)
	await wait_frames(2)
	
	m.start_tutorial()
	assert_eq(m.rules_label.text, BASE_JA)
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 32)
	
	m.end_tutorial()
	assert_eq(m.rules_label.text, BASE_JA + "\n? の岩には宇宙人を置けない。 数字は、まわりの 8 マスにいる宇宙人の数。")
	assert_eq(m.rules_label.get_theme_font_size("font_size"), 24)

## CHECK: 5
func test_rules_panel_text() -> void:
	var RulesPanel = load("res://scenes/rules_panel.gd")
	var ja_text = RulesPanel.rules_text("ja")
	assert_true(ja_text.find("・? の岩には、宇宙人を置けない。") >= 0)
	assert_false(ja_text.find("・岩のマスには、宇宙人を置けない。") >= 0)
	assert_eq(ja_text.split("\n").size(), 19)
	
	var en_text = RulesPanel.rules_text("en")
	assert_true(en_text.find("- You cannot place an alien on a ? rock.") >= 0)
	assert_false(en_text.find("- You cannot place an alien on a rock.") >= 0)
	assert_eq(en_text.split("\n").size(), 17)
