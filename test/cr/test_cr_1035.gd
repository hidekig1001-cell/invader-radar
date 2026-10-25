extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const RulesLabelScript = preload("res://scenes/rules_label.gd")

func _start_main(language: String):
	var m = MainScene.instantiate()
	m.language = language
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1035_main_ja_language_sets_rules_text() -> void:
	var m = await _start_main("ja")
	assert_eq(m.rules_label.text, "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。")

## CHECK: 2
func test_cr_1035_apply_language_ja_sets_rules_text() -> void:
	var label = RulesLabelScript.new()
	add_child_autofree(label)
	label.apply_language("ja")
	assert_eq(label.text, "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。")
	label.apply_language("en")
	assert_eq(label.text, "ONE ALIEN PER ROW, COLUMN AND COLOR.\nALIENS MUST NOT TOUCH, EVEN DIAGONALLY.")
