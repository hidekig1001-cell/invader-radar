# クラウドへの依頼: InvaderRadar改修1190 の R3'（テストを読む）（1 回目、2026-10-27 19:3x、Invader Radar31）

依頼と CR は branch review/cr1190-r0p の briefs/ir_cr1190_r0p.md（R0' は OK、results/cr1190_r0p.md）。main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183）。まだ無い関数をファイルの頭の preload の const から呼ぶと、ファイルごと Parse Error になり GUT が飛ばして「全部通過」に見える（1188）。関数の中の load で呼んでいるかも見る。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値（parse の戻り値 true、region_count 4、region_at の 0〜3、to_dict の regions の値まるごと、右下の区域の dead_marks と filled_lines の値まるごと）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（46fc619）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1190-r3p のファイル results/cr1190_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1921-CR-1190
== tests/test_cr_1190.gd
extends GutTest

const Level = preload("res://game/level.gd")
const Rules = preload("res://core/rules.gd")
const BS = preload("res://core/board_state.gd")


## CHECK: 1
func test_cr_1190_remap_region_indices() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	assert_eq(level.region_count(), 4)
	assert_eq(level.region_at(0, 0), 0)
	assert_eq(level.region_at(2, 0), 1)
	assert_eq(level.region_at(0, 2), 2)
	assert_eq(level.region_at(3, 3), 3)
	var d = level.to_dict()
	assert_eq(d["regions"], [
		[0, 0, 1, 1],
		[0, 0, 1, 1],
		[2, 2, 3, 3],
		[2, 2, 3, 3]
	])


## CHECK: 2
func test_cr_1190_dead_marks_with_remap() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	var b = BS.new(4, 4)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	var marks = Rules.dead_marks(b, level)
	assert_eq(marks.size(), 4)
	# The order in the CR is [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]
	# We check if the array contains these elements. Since order might vary by implementation details of iteration,
	# but CR says "is [ ... ]", we assume strict order or at least presence.
	# Given the instruction "write the expected value in the order written in the CR", we compare directly.
	assert_eq(marks, [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)])


## CHECK: 3
func test_cr_1190_filled_lines_with_remap() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	var lines = Rules.filled_lines(b, level)
	assert_eq(lines.size(), 1)
	if lines.size() > 0:
		var line = lines[0]
		assert_eq(line["kind"], "region")
		assert_eq(line["index"], 3)
		assert_eq(line["cells"], [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)])
	else:
		assert_true(false, "Expected one filled line")

== 既存のテストの書き直し
== 終わり
