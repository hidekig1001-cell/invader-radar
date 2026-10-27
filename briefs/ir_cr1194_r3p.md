# クラウドへの依頼: InvaderRadar改修1194 の R3'（テストを読む）（1 回目、2026-10-27 22:1x、Invader Radar32）

依頼と CR は branch review/cr1194-r0p の briefs/ir_cr1194_r0p.md（R0' は OK、results/cr1194_r0p.md）。main は 82eb05b（v2.01-cr1191）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
この run は AuteDev の新しい版（release_52ef0ce）で流れた。材料に「注意（機械の印）」の節があれば、それも読んで、当たっているかを書く。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」・「数と各要素」に分けた形は NG（1183・1190）。まだ無い関数をファイルの頭の preload の const から呼ぶと、ファイルごと Parse Error になり GUT が飛ばして「全部通過」に見える（1188）。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目の手順と期待値（size_up_tile_text の日本語と英語の文の値まるごと、「タップではじめる」「TAP TO START」が消える、ほかの札の文は変わらない）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（82eb05b）でも成り立ってしまわないか（新しいテストのどの関数も今の main で落ちるか）。
3. 既存のテストの書き直し 3 つ（test_cr_1172_size_up_tile_ja・test_cr_1172_size_up_tile_en・test_cr_1178_size_up_wait_and_age）が、依頼の「変わる既存のテスト」に書いた表明だけを変えているか。依頼に無い表明の追加・削除・ほかの関数の書き換えが無いか。

終わりの条件: 結果を branch review/cr1194-r3p のファイル results/cr1194_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-2201-CR-1194
== tests/test_cr_1194.gd
extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_levels() -> Array:
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	return [l1, l2, l3]


func _start_main(language: String) -> Node:
	var levels = _make_levels()
	var m = MainScene.instantiate()
	m.language = language
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1194_size_up_tile_text_ja() -> void:
	var m = await _start_main("ja")
	m.session.solve_now()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	m.tick_size_up(0.7)
	assert_eq(m.size_up_tile_text(), "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)


## CHECK: 2
func test_cr_1194_size_up_tile_text_en() -> void:
	var m = await _start_main("en")
	m.session.solve_now()
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	m.tick_size_up(0.7)
	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.get_line_count(), 2)
== 既存のテストの書き直し
-- test__cr__test_cr_1172.gd
27c27
< 	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる")
---
> 	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")
62,63c62,63
< 	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START")
< 	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START")
---
> 	assert_eq(m.size_up_tile_text(), "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
> 	assert_eq(m.bubble.text, "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!")
-- test__cr__test_cr_1178.gd
39c39
< 	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる")
---
> 	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！")
== 終わり
