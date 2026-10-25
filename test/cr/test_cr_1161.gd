extends GutTest


## CHECK: 1
func test_cr_1161_check_1() -> void:
	var TS = load("res://game/tutorial_steps.gd")
	var steps = TS.steps()
	assert_eq(steps[0]["text"], "EACH COLOR NEEDS ONE ALIEN.\nDOUBLE TAP THE GREEN CELL.")
	assert_eq(steps[1]["text"], "ONE ALIEN PER ROW AND COLUMN, TOO.\nMARK AN X ON THE 6 CELLS.")
	assert_eq(steps[2]["text"], "ALIENS CANNOT TOUCH DIAGONALLY EITHER.\nMARK AN X ON EACH DIAGONAL CELL.")
	assert_eq(steps[4]["text"], "NOW PLACE THE LAST TWO ALIENS.")
	assert_eq(TS.apply_language("ja", 0), "各色に宇宙人を 1 人置く。\n緑のマスをダブルタップ")
	assert_eq(TS.apply_language("ja", 4), "残りの 2 人の宇宙人を置く。")
