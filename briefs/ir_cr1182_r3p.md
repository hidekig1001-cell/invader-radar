# クラウドへの依頼: InvaderRadar改修1182 の R3'（テストを読む）（2026-10-27 05:3x、Invader Radar29）

依頼と CR は branch review/cr1182-r0p-2 の briefs/ir_cr1182_r0p2.md（R0' は 2 回目で OK、results/cr1182_r0p_2.md）。main は 0f865a6（v1.90-cr1181。1181 の wrong の 250 ms・0.3 が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか。
2. 期待値が今の main（0f865a6）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが、依頼の「変わる既存のテスト」の 8 つ（test_cr_1179 の 7 つ、test_cr_1180_main_vibrate_on_dead_transition）の「A は B に変わる」どおりか（retrigger・next_level の「（2 か所とも）」は 2 か所とも替える意味）。それ以外の行を変えていないか、「変わらない既存のテスト」（test_cr_1180 の 5 つなど）と test_cr_1181 を書き換えていないか。

終わりの条件: 結果を branch review/cr1182-r3p のファイル results/cr1182_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run 20261027-0524-CR-1182 のテストと、既存のテストの書き直しの main との差分）
== tests/test_cr_1182.gd
extends GutTest

const LevelScript = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


func _make_main_with_level():
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
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1182_dead_vibration_duration_and_amplitude() -> void:
	var m = await _make_main_with_level()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])


## CHECK: 2
func test_cr_1182_dead_vibration_on_swipe() -> void:
	var m = await _make_main_with_level()
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.sound.vibration_amplitudes, [0.3])


## CHECK: 3
func test_cr_1182_dead_vibration_not_retriggered() -> void:
	var m = await _make_main_with_level()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4])
== 既存のテストの書き直し
-- test__cr__test_cr_1179.gd
52c52
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
69c69
< 	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 15, 250])
81c81
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
86c86
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
91c91
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])
96c96
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 250])
105c105,106
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [250])
> 	assert_eq(m.sound.vibration_amplitudes, [0.3])
118c119
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
122c123
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
130c131
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 15, 250])
151c152
< 	assert_eq(m.sound.vibrations, [15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 250])
169c170
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 15, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 15, 250])
-- test__cr__test_cr_1180.gd
94,95c94,95
< 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
< 	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, -1.0])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 250])
> 	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3])
== 終わり
