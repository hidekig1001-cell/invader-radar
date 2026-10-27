extends GutTest

const LevelScript = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_hud() -> Node:
	var Hud = load("res://scenes/hud.gd")
	var hud = Hud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	return hud


func _make_main_with_levels(levels: Array) -> Node:
	var m = MainScene.instantiate()
	m.language = "ja"
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _make_level(id: int, width: int, height: int, target: int, regions: Array):
	var l = LevelScript.new()
	l.parse({
		"id": id,
		"width": width,
		"height": height,
		"target": target,
		"regions": regions
	})
	return l


## CHECK: 1
func test_cr_1195_alien_labels_localized_and_styled() -> void:
	var Hud = load("res://scenes/hud.gd")
	var hud = await _make_hud()
	
	hud.set_language("ja")
	assert_eq(hud.aliens_name_label.text, "残り宇宙人")
	
	hud.set_language("en")
	assert_eq(hud.aliens_name_label.text, "ALIENS LEFT")
	
	var c: Rect2 = Hud.table_cell_rect(0, 1)
	assert_eq(hud.aliens_name_label.position, c.position + Vector2(16, 0))
	assert_eq(hud.aliens_label.position, c.position + Vector2(16, 0))
	assert_eq(hud.aliens_name_label.size, c.size - Vector2(32, 0))
	assert_eq(hud.aliens_label.size, c.size - Vector2(32, 0))
	assert_eq(hud.aliens_name_label.horizontal_alignment, HORIZONTAL_ALIGNMENT_LEFT)
	assert_eq(hud.aliens_label.horizontal_alignment, HORIZONTAL_ALIGNMENT_RIGHT)
	assert_eq(hud.aliens_label.get_theme_font_size("font_size"), 40)
	assert_eq(hud.aliens_label.get_theme_color("font_color"), Color8(245, 240, 255))


## CHECK: 2
func test_cr_1195_aliens_left_logic_and_update() -> void:
	var Hud = load("res://scenes/hud.gd")
	var hud = await _make_hud()
	
	assert_eq(Hud.aliens_left({"board": {"width": 5, "pieces": 2}}), 3)
	assert_eq(Hud.aliens_left({"board": {"width": 5, "pieces": 7}}), 0)
	assert_eq(Hud.aliens_left({"level": 1, "score": 0, "hints": 3, "moves": 0, "status": "playing"}), 0)
	
	hud.update_from({
		"level": 1, 
		"score": 0, 
		"hints": 3, 
		"moves": 0, 
		"status": "playing", 
		"board": {"width": 5, "height": 5, "marks": 4, "pieces": 2}
	})
	assert_eq(hud.aliens_label.text, "3")
	
	hud.update_from({
		"level": 1, 
		"score": 0, 
		"hints": 3, 
		"moves": 0, 
		"status": "playing", 
		"board": {"width": 5, "height": 5, "marks": 0, "pieces": 7}
	})
	assert_eq(hud.aliens_label.text, "0")
	
	hud.update_from({
		"level": 7, 
		"score": 120, 
		"hints": 2, 
		"moves": 9, 
		"status": "playing"
	})
	assert_eq(hud.aliens_label.text, "0")
	assert_eq(hud.level_label.text, "7")
	assert_eq(hud.moves_label.text, "9")


## CHECK: 3
func test_cr_1195_main_session_updates_alien_count() -> void:
	var l1 = _make_level(1, 4, 4, 4, [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]])
	var l2 = _make_level(2, 5, 5, 5, [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]])
	var m = await _make_main_with_levels([l1, l2])
	
	assert_eq(m.hud.aliens_label.text, "4")
	
	m.session.double_tap(0, 0)
	assert_eq(m.hud.aliens_label.text, "3")
	
	m.session.tap(2, 2)
	assert_eq(m.hud.aliens_label.text, "3")
	
	m.session.double_tap(0, 0)
	assert_eq(m.hud.aliens_label.text, "4")
	
	m.session.double_tap(0, 0)
	m.session.undo()
	assert_eq(m.hud.aliens_label.text, "4")
	
	m.session.double_tap(0, 0)
	m.session.double_tap(1, 0)
	m.session.double_tap(2, 0)
	m.session.double_tap(3, 0)
	assert_eq(m.hud.aliens_label.text, "0")
	
	m.session.double_tap(0, 2)
	assert_eq(m.session.board.pieces().size(), 5)
	assert_eq(m.hud.aliens_label.text, "0")
	
	m.session.restart_level()
	assert_eq(m.hud.aliens_label.text, "4")


## CHECK: 4
func test_cr_1195_solve_next_and_snapshot_keys() -> void:
	var l1 = _make_level(1, 4, 4, 4, [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]])
	var l2 = _make_level(2, 5, 5, 5, [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]])
	var m = await _make_main_with_levels([l1, l2])
	
	m.session.solve_now()
	assert_eq(m.hud.aliens_label.text, "0")
	
	m.session.next_level()
	assert_eq(m.hud.aliens_label.text, "5")
	
	var keys: Array = m.session.snapshot().keys()
	assert_eq(keys, ["level", "moves", "score", "hints", "status", "board"])
