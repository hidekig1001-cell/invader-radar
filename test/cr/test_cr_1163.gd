extends GutTest

const RulesPanelScript = preload("res://scenes/rules_panel.gd")


func test_rules_text_ja() -> void:
	## CHECK: 1
	var RP = load("res://scenes/rules_panel.gd")
	var expected := "ルール\n・各行・各列・各色に、\n　宇宙人を 1 人ずつ置く。\n・宇宙人どうしは、縦・横・斜めにも\n　隣り合ってはいけない。\n・数字は、まわりの 8 マスにいる\n　宇宙人の数。\n　数字のマスに宇宙人はいない。\n・岩のマスには、宇宙人を置けない。\n\n操作\n・タップ: ×\n・ダブルタップ: 宇宙人\n・スワイプ: なぞったマスに ×\n\nボタン\n・ヒント: 次の 1 手を教える\n・戻す: 1 手戻す\n・やり直す: この面を最初から"
	assert_eq(RP.rules_text("ja"), expected)


func test_rules_text_en() -> void:
	## CHECK: 1
	var RP = load("res://scenes/rules_panel.gd")
	var expected := "RULES\n- One alien in each row, column and color.\n- Aliens must not touch, even diagonally.\n- A number tells how many aliens\n  are in the 8 cells around it.\n  No alien is on a number cell.\n- You cannot place an alien on a rock.\n\nCONTROLS\n- Tap: X\n- Double tap: alien\n- Swipe: X on the cells you swipe\n\nBUTTONS\n- Hint: shows the next move\n- Undo: takes back one move\n- Restart: starts this level over"
	assert_eq(RP.rules_text("en"), expected)


func test_layout_ja() -> void:
	## CHECK: 2
	var RP = load("res://scenes/rules_panel.gd")
	var p = RP.new()
	add_child_autofree(p)
	await wait_frames(1)
	p.open("ja")
	await wait_frames(1)
	assert_eq(p.body_label.get_line_count(), 19)
	assert_true(p.body_label.get_combined_minimum_size().y <= p.body_label.size.y)


func test_layout_en() -> void:
	## CHECK: 2
	var RP = load("res://scenes/rules_panel.gd")
	var p = RP.new()
	add_child_autofree(p)
	await wait_frames(1)
	p.open("en")
	await wait_frames(1)
	assert_eq(p.body_label.get_line_count(), 17)


func test_body_label_position_and_size() -> void:
	## CHECK: 2
	var RP = load("res://scenes/rules_panel.gd")
	var p = RP.new()
	add_child_autofree(p)
	await wait_frames(1)
	p.open("ja")
	await wait_frames(1)
	assert_eq(p.body_label.position, Vector2(90, 240))
	assert_true(p.body_label.position.y + p.body_label.size.y <= p.close_button.position.y)
