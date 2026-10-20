extends GutTest

const TutorialSteps = preload("res://game/tutorial_steps.gd")
const MainScene = preload("res://scenes/main.tscn")


func _start_main(language: String):
	var m = MainScene.instantiate()
	m.language = language
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_apply_language_ja_step0() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 0), "各色に駒を 1 つ置く。\n緑のマスをダブルタップ")


## CHECK: 2
func test_apply_language_ja_step1() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 1), "各行・各列にも 1 つ。\n6 つのマスに × を付ける")


## CHECK: 3
func test_apply_language_ja_step2() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 2), "斜めにも隣り合えない。\n斜めのマスに × を付ける")


## CHECK: 4
func test_apply_language_ja_step3() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 3), "紫は 1 マスだけ。\nそこをダブルタップ")


## CHECK: 5
func test_apply_language_ja_step4() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 4), "残りの 2 つの駒を置く。")


## CHECK: 6
func test_apply_language_ja_step5() -> void:
	assert_eq(TutorialSteps.apply_language("ja", 5), "よくできました！\nタップで開始")


## CHECK: 7
func test_main_tutorial_bubble_ja_step0() -> void:
	var m = await _start_main("ja")
	m.start_tutorial()
	assert_eq(m.bubble.text, TutorialSteps.apply_language("ja", 0))


## CHECK: 8
func test_main_tutorial_bubble_ja_step1() -> void:
	var m = await _start_main("ja")
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.bubble.text, TutorialSteps.apply_language("ja", 1))


## CHECK: 9
func test_main_tutorial_bubble_ja_step2() -> void:
	var m = await _start_main("ja")
	m.start_tutorial()
	m.tutorial_input("double_tap", Vector2i(3, 1))
	m.tutorial_input("tap", Vector2i(0, 1))
	m.tutorial_input("tap", Vector2i(1, 1))
	m.tutorial_input("tap", Vector2i(2, 1))
	m.tutorial_input("tap", Vector2i(3, 0))
	m.tutorial_input("tap", Vector2i(3, 2))
	m.tutorial_input("tap", Vector2i(3, 3))
	assert_eq(m.bubble.text, TutorialSteps.apply_language("ja", 2))
