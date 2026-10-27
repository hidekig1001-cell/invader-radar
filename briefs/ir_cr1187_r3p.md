# クラウドへの依頼: InvaderRadar改修1187 の R3'（テストを読む）（1 回目、2026-10-27 16:4x、Invader Radar30）

依頼と CR は branch review/cr1187-r0p の briefs/ir_cr1187_r0p.md（R0' は OK、results/cr1187_r0p.md）。main は 0ae3435（v1.94-cr1185）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183）。
注意: この run は、手元で別の当て試し（1188）が同じ WSL で流れている間に始まった。テストの結果に test_cr_1051（保存のファイル）の落ちがあっても、それはこの改修のせいではない見込み。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値（played の最後と count("dead")、vibrations の並びを値まるごと）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（0ae3435）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが、依頼の「変わる既存のテスト」の 2 つ（test_cr_1179_main_dead_retrigger・test_cr_1182_dead_vibration_not_retriggered）の書いた所だけで、ほかの表明を足したり消したりしていないか（「変えない」と書いた最初の 2 つの表明・関数の名前・コメントが残っているか）。

終わりの条件: 結果を branch review/cr1187-r3p のファイル results/cr1187_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1633-CR-1187
== tests/test_cr_1187.gd
extends GutTest

const Level = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")

func _make_level() -> Level:
	var level = Level.new()
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

func _make_main(level: Level) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1187_new_dead_group_region() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Tap in region 3 (not forming a new dead group yet, just marking)
	m.session.tap(2, 2)
	assert_eq(m.sound.played[-1], "mark")
	assert_eq(m.sound.played.count("dead"), 1)
	
	# Complete region 3 with X
	m.session.tap(3, 2)
	m.session.tap(2, 3)
	m.session.tap(3, 3)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])

## CHECK: 2
func test_cr_1187_new_dead_group_line() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Fill row 0 in region 1 (cells 2,0 and 3,0). This creates a new dead group (row 0 is all X).
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])

## CHECK: 3
func test_cr_1187_undo_dead_group() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	
	# Fill region 0 with X
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	
	# Double tap (1,1) to place alien. Region 0 is no longer all X.
	m.session.double_tap(1, 1)
	assert_eq(m.sound.played[-1], "line") # Or whatever sfx corresponds to clearing the dead state / placing alien. The prompt says "line" for this step in test 3 description? 
	# Wait, prompt says: "m.session.double_tap(1, 1) をしたあと... m.sound.played[-1] は \"line\""
	assert_eq(m.sound.vibrations, [15, 15, 15, 250]) # No new vibration for line? Or maybe line has no vibration in this context? 
	# Actually, looking at CR-1187 description: "sfx_name が \"mark\" か \"clear\" で... sfx_name を \"dead\" にする".
	# If we place an alien, it's a "place" or "line" event. It removes the dead state.
	# The prompt explicitly says: m.sound.played[-1] は "line", m.sound.vibrations は [15, 15, 15, 250].
	# This implies the double_tap triggered a "line" sound (maybe because it completed a line? No, region 0 is not a line. 
	# Ah, `Rules.filled_lines` might consider the row/col if they are full? 
	# Let's trust the prompt's expected values.
	
	# Undo: (1,1) becomes X again. Region 0 is all X again. This is a "clear" action effectively restoring the dead state.
	m.session.undo()
	
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 250])
== 既存のテストの書き直し
-- test__cr__test_cr_1179.gd
85,86c85,86
< 	assert_eq(m.sound.played.count("dead"), 1)
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
---
> 	assert_eq(m.sound.played.count("dead"), 2)
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])
90,91c90,91
< 	assert_eq(m.sound.played.count("dead"), 1)
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
---
> 	assert_eq(m.sound.played.count("dead"), 2)
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])
95,96c95,96
< 	assert_eq(m.sound.played.count("dead"), 2)
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 250])
---
> 	assert_eq(m.sound.played.count("dead"), 3)
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250, 250])
-- test__cr__test_cr_1182.gd
60,61c60,61
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
< 	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250])
> 	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.3])
== 終わり
