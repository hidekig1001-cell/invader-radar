extends GutTest

const RULES_LABEL_SCRIPT = preload("res://scenes/rules_label.gd")
const MAIN_SCENE = preload("res://scenes/main.tscn")


## CHECK: 1
func test_cr_1158_rules_label_text_ja() -> void:
	var label = RULES_LABEL_SCRIPT.new()
	add_child_autofree(label)
	label.apply_language("ja")
	assert_eq(label.text, "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。")


## CHECK: 1
func test_cr_1158_rules_label_text_en() -> void:
	var label = RULES_LABEL_SCRIPT.new()
	add_child_autofree(label)
	label.apply_language("en")
	assert_eq(label.text, "ONE ALIEN PER ROW, COLUMN AND COLOR.\nALIENS MUST NOT TOUCH, EVEN DIAGONALLY.")


## CHECK: 2
func test_cr_1158_main_ja_rules_text_and_size() -> void:
	var m = MAIN_SCENE.instantiate()
	m.language = "ja"
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.rules_label.text, "各行・各列・各色に宇宙人を 1 人置く。\n宇宙人どうしは縦・横・斜めにも隣り合ってはいけない。")
	assert_true(m.rules_label.get_combined_minimum_size().x <= 972.0)

