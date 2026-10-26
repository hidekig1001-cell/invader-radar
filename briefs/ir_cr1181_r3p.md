# クラウドへの依頼: InvaderRadar改修1181 の R3'（テストを読む）（2026-10-27 05:0x、Invader Radar29）

依頼と CR は branch review/cr1181-r0p の briefs/ir_cr1181_r0p.md（R0' は OK 済み、results/cr1181_r0p.md）。main は a12daf1（v1.89-cr1180）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか。
2. 期待値が今の main（a12daf1）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1181-r3p のファイル results/cr1181_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run 20261027-0458-CR-1181 のテストと、既存のテストの書き直しの main との差分）
== tests/test_cr_1181.gd
extends GutTest

const LevelScript = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


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
func test_cr_1181_diagonal_collision_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.session.double_tap(0, 0)
	assert_eq(m.sound.vibrations.size(), 1)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 1)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)

	m.session.double_tap(1, 1)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)


## CHECK: 2
func test_cr_1181_vertical_collision_and_removal_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.session.double_tap(0, 0)
	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)

	m.session.double_tap(0, 3)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)

	m.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations.size(), 3)
	assert_eq(m.sound.vibrations[2], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 3)
	assert_eq(m.sound.vibration_amplitudes[2], -1.0)


## CHECK: 3
func test_cr_1181_tutorial_collision_vibration() -> void:
	var level = _make_level()
	var m = await _make_main(level)

	m.start_tutorial()
	assert_not_null(m.tutorial)

	m.tutorial.session.double_tap(3, 1)
	assert_eq(m.sound.vibrations.size(), 1)
	assert_eq(m.sound.vibrations[0], 30)
	assert_eq(m.sound.vibration_amplitudes.size(), 1)
	assert_eq(m.sound.vibration_amplitudes[0], -1.0)

	m.tutorial.session.double_tap(2, 1)
	assert_eq(m.sound.vibrations.size(), 2)
	assert_eq(m.sound.vibrations[1], 250)
	assert_eq(m.sound.vibration_amplitudes.size(), 2)
	assert_eq(m.sound.vibration_amplitudes[1], 0.3)
== 既存のテストの書き直し
== 終わり
