# クラウドへの依頼: InvaderRadar改修1180 の R3'（テストを読む、1179 の後の版）（2026-10-27 04:2x、Invader Radar29）

依頼と CR は branch review/cr1180-r0p-2 の briefs/ir_cr1180b_r0p.md（R0' は OK 済み、results/cr1180_r0p_2.md）。main は fd8c810（v1.88-cr1179）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜6 の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか。
2. 期待値が今の main（fd8c810）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが、依頼の「変わる既存のテスト」の 7 つ（test_cr_1177 の 1 つ、test_cr_1179 の 6 つ）の「A は B に変わる」どおりか。それ以外の行を変えていないか、「変わらない既存のテスト」を書き換えていないか。

終わりの条件: 結果を branch review/cr1180-r3p のファイル results/cr1180_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run 20261027-0414-CR-1180 のテストと、既存のテストの書き直しの main との差分）
== tests/test_cr_1180.gd
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
func test_cr_1180_sound_vibrate_amplitude() -> void:
	var S = load("res://scenes/sound.gd")
	var s = S.new()
	add_child_autofree(s)
	s.vibrate(30)
	s.vibrate(15, 0.4)
	assert_eq(s.vibrations, [30, 15])
	assert_eq(s.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 2
func test_cr_1180_main_vibrate_on_place_and_mark() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [30])
	assert_eq(m.sound.vibration_amplitudes, [-1.0])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 3
func test_cr_1180_main_vibrate_sequence() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15])
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [15, 30])
	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations, [15, 30])
	m.session.tap(3, 3)
	assert_eq(m.sound.vibrations, [15, 30, 15])
	assert_eq(m.sound.vibration_amplitudes, [0.4, -1.0, 0.4])

## CHECK: 4
func test_cr_1180_main_vibrate_on_swipe() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	assert_eq(m.sound.vibrations, [15])
	assert_eq(m.sound.vibration_amplitudes, [0.4])

## CHECK: 5
func test_cr_1180_main_vibrate_in_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.start_tutorial()
	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations, [30])
	m.tutorial.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [30, 15])
	assert_eq(m.sound.vibration_amplitudes, [-1.0, 0.4])

## CHECK: 6
func test_cr_1180_main_vibrate_on_dead_transition() -> void:
	var level = _make_level()
	var m = await _make_main(level)
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15])
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
	assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, -1.0])
== 既存のテストの書き直し
-- test__cr__test_cr_1177.gd
30c30
< 	# Mark X (tap) -> should NOT add vibration
---
> 	# Mark X (tap) -> should add vibration
32c32
< 	assert_eq(m.sound.vibrations, [30])
---
> 	assert_eq(m.sound.vibrations, [30, 15])
-- test__cr__test_cr_1179.gd
47c47
< 	assert_eq(m.sound.vibrations, [])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15])
52c52
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
64c64
< 	assert_eq(m.sound.vibrations, [30])
---
> 	assert_eq(m.sound.vibrations, [30, 15, 15, 15])
69c69
< 	assert_eq(m.sound.vibrations, [30, 120])
---
> 	assert_eq(m.sound.vibrations, [30, 15, 15, 15, 15, 120])
81c81
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
86c86
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15])
91c91
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15])
96c96
< 	assert_eq(m.sound.vibrations, [120, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15, 120])
118c118
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
122c122
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120])
130c130
< 	assert_eq(m.sound.vibrations, [120, 120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 120, 15, 15, 15, 120])
146c146
< 	assert_eq(m.sound.vibrations, [])
---
> 	assert_eq(m.sound.vibrations, [15])
151c151
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 120])
161c161
< 	assert_eq(m.sound.vibrations, [])
---
> 	assert_eq(m.sound.vibrations, [15])
169c169
< 	assert_eq(m.sound.vibrations, [120])
---
> 	assert_eq(m.sound.vibrations, [15, 15, 15, 15, 120])
== 終わり
