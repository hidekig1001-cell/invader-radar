# クラウドへの依頼: InvaderRadar改修1189 の R3'（テストを読む）（1 回目、2026-10-27 19:2x、Invader Radar31）

依頼と CR は branch review/cr1189-r0p の briefs/ir_cr1189_r0p.md（R0' は OK、results/cr1189_r0p.md）。main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183）。まだ無い関数をファイルの頭の preload の const から呼ぶと、ファイルごと Parse Error になり GUT が飛ばして「全部通過」に見える（1188）。関数の中の load で呼んでいるかも見る。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値（add_child_autofree の前に盤を置く、立ち上げ直後の played・vibrations が []、そのあとの手で ["mark"]・[15]、["dead"]・[250]）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（46fc619）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state の 2 か所（立ち上げたあとの [15] → []、tap(1, 1)・tap(1, 1) のあとの [15, 250] → [250]）だけで、ほかの表明・手を変えていないか。ほかの既存のテストに書き直しが無いか。

終わりの条件: 結果を branch review/cr1189-r3p のファイル results/cr1189_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1913-CR-1189
== tests/test_cr_1189.gd
extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const Main = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1189_no_sfx_on_initial_refresh_with_alien_and_marks() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 2, 0)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(3, 1)
	assert_eq(m.sound.played, ["mark"])
	assert_eq(m.sound.vibrations, [15])

## CHECK: 2
func test_cr_1189_no_sfx_on_initial_refresh_with_collision() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("place", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])

## CHECK: 3
func test_cr_1189_no_sfx_on_initial_refresh_with_dead_marks() -> void:
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]})
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played, ["dead"])
	assert_eq(m.sound.vibrations, [250])
== 既存のテストの書き直し
-- test__cr__test_cr_1179.gd
146c146
< 	assert_eq(m.sound.vibrations, [15])
---
> 	assert_eq(m.sound.vibrations, [])
151c151
< 	assert_eq(m.sound.vibrations, [15, 250])
---
> 	assert_eq(m.sound.vibrations, [250])
== 終わり
