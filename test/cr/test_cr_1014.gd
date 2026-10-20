extends GutTest

## CHECK: 1
func test_step_1_text_is_shortened() -> void:
	var steps = preload("res://game/tutorial_steps.gd").steps()
	assert_eq(steps[1]["text"], "ONE PIECE PER ROW AND COLUMN, TOO.\nMARK AN X ON THE 6 CELLS.")
