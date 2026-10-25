extends GutTest

const RulesPanel = preload("res://scenes/rules_panel.gd")

## CHECK: 1
func test_rules_text_ja() -> void:
	var expected := "ルール\n・各行・各列・各色に、\n　宇宙人を 1 人ずつ置く。\n・宇宙人どうしは、縦・横・斜めにも\n　隣り合ってはいけない。\n・数字は、まわりの 8 マスにいる\n　宇宙人の数。\n　数字のマスに宇宙人はいない。\n・岩のマスには、宇宙人を置けない。\n\n操作\n・タップ: ×\n・ダブルタップ: 宇宙人\n・スワイプ: なぞったマスに ×\n\nボタン\n・ヒント: 次の 1 手を教える\n・戻す: 1 手戻す\n・やり直す: この面を最初から"
	var actual := RulesPanel.rules_text("ja")
	assert_eq(actual, expected)

## CHECK: 1
func test_rules_text_en() -> void:
	var expected := "RULES\n- One alien in each row, column and color.\n- Aliens must not touch, even diagonally.\n- A number tells how many aliens\n  are in the 8 cells around it.\n  No alien is on a number cell.\n- You cannot place an alien on a rock.\n\nCONTROLS\n- Tap: X\n- Double tap: alien\n- Swipe: X on the cells you swipe\n\nBUTTONS\n- Hint: shows the next move\n- Undo: takes back one move\n- Restart: starts this level over"
	var actual := RulesPanel.rules_text("en")
	assert_eq(actual, expected)
