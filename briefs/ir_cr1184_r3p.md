# クラウドへの依頼: InvaderRadar改修1184 の R3'（テストを読む）（1 回目、2026-10-27 11:1x、Invader Radar30）

依頼と CR は branch review/cr1184-r0p の briefs/ir_cr1184_r0p.md（R0' は OK、results/cr1184_r0p.md）。main は 5f52a46（v1.92-cr1183）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183、値まるごとの assert_eq にさせる）。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜10 の手順と期待値（m.sound.played[-1] と m.sound.played.count("line")、8 は m.session.status と count）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手（tap・double_tap・apply）や表明が無いか。
2. 期待値が今の main（5f52a46）でも成り立ってしまわないか（どの関数も今の main で落ちるか。1・2〜10 の line の表明が今の main で落ちるか）。
3. 既存のテストの書き直しが、依頼の「変わる既存のテスト」の 1 つ（test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien の振動の並び 2 か所: [30, 15, 15, 15] → [30, 15, 15]、[30, 15, 15, 15, 15, 250] → [30, 15, 15, 15, 250]）だけで、ほかの表明を足したり消したりしていないか。

終わりの条件: 結果を branch review/cr1184-r3p のファイル results/cr1184_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1106-CR-1184
== tests/test_cr_1184.gd
extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")
const LevelScript = preload("res://game/level.gd")

func _make_level() -> LevelScript:
	var level = LevelScript.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		]
	})
	return level

func _make_main(level: LevelScript) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1184_sound_line() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("line")
	assert_eq(s.played, ["line"])

## CHECK: 2
func test_cr_1184_line_on_place_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(0, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 3
func test_cr_1184_line_on_mark_completion_and_new_region() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 2)

## CHECK: 4
func test_cr_1184_line_retrigger_on_mark_toggle() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 2)

## CHECK: 5
func test_cr_1184_line_on_alien_removal_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	m.session.double_tap(0, 2)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(0, 2)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 6
func test_cr_1184_line_on_alien_removal_and_mark_completion() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	m.session.double_tap(2, 0)
	m.session.tap(1, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.double_tap(2, 0)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(2, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 7
func test_cr_1184_no_line_on_initial_load_with_lines() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 8
func test_cr_1184_line_on_completion_before_clear() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	m.session.board.apply("place", 1, 0)
	m.session.board.apply("place", 3, 1)
	m.session.board.apply("place", 0, 2)
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	m.session.board.apply("mark", 2, 1)
	m.session.board.apply("mark", 1, 2)
	m.session.board.apply("mark", 3, 2)
	m.session.board.apply("mark", 0, 3)
	m.session.board.apply("mark", 1, 3)
	m.session.board.apply("mark", 3, 3)
	add_child_autofree(m)
	await wait_frames(2)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
	m.session.double_tap(2, 3)
	assert_eq(m.session.status, "cleared")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 9
func test_cr_1184_no_line_in_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.played.count("line"), 0)
	m.end_tutorial()
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)

## CHECK: 10
func test_cr_1184_dead_priority_over_line() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 1)
	m.session.tap(3, 2)
	m.session.tap(3, 3)
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("line"), 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "line")
	assert_eq(m.sound.played.count("line"), 1)
== 既存のテストの書き直し
-- test__cr__test_cr_1179.gd
64c64
< 	assert_eq(m.sound.vibrations, [30, 15, 15, 15])
---
> 	assert_eq(m.sound.vibrations, [30, 15, 15])
69c69
< 	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 15, 250])
---
> 	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 250])
== 終わり
