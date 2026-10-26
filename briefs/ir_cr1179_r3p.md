# クラウドへの依頼: IR CR-1179 の R3'（テストを読む）（2026-10-27 00:1x、Invader Radar改修28）

依頼と CR は branch review/cr1179-r0p の briefs/ir_cr1179_r0p.md（R0' は OK 済み）。main は e6cf4ca（CR-1177 の vibrate が入った版）。アプリのコードは書き換えない。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜8 の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか。
2. 期待値が今の main（e6cf4ca）でも成り立ってしまわないか。
3. 既存のテストの書き直しが無いこと（依頼も「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1179-r3p のファイル results/cr1179_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。main・ほかの branch には触らない。

## 材料（run 20261026-2254-CR-1179 のテスト）
== tests/test_cr_1179.gd
extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")
const LevelScript = preload("res://game/level.gd")
const SoundScript = preload("res://scenes/sound.gd")

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

func _make_main(levels: Array) -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new(levels)
	add_child_autofree(m)
	await wait_frames(2)
	return m

## CHECK: 1
func test_cr_1179_sound_dead_sfx() -> void:
	var s = SoundScript.new()
	add_child_autofree(s)
	s.setup()
	s.play_sfx("dead")
	assert_eq(s.played, ["dead"])

## CHECK: 2
func test_cr_1179_main_dead_transition() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])

## CHECK: 3
func test_cr_1179_main_dead_with_alien() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [30])
	
	m.session.tap(2, 1)
	m.session.tap(3, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [30, 120])

## CHECK: 4
func test_cr_1179_main_dead_retrigger() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])
	
	m.session.tap(2, 0)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])
	
	m.session.tap(1, 1)
	m.session.tap(3, 0)
	assert_eq(m.sound.played.count("dead"), 1)
	assert_eq(m.sound.vibrations, [120])
	
	m.session.tap(3, 0)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [120, 120])

## CHECK: 5
func test_cr_1179_main_dead_swipe() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)])
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])

## CHECK: 6
func test_cr_1179_main_dead_next_level() -> void:
	var level_a = _make_level()
	var level_b = _make_level()
	var level_c = _make_level()
	var m = await _make_main([level_a, level_b, level_c])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.vibrations, [120])
	
	m.session.next_level()
	assert_eq(m.session.level_index, 1)
	assert_eq(m.sound.vibrations, [120])
	
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.played.count("dead"), 2)
	assert_eq(m.sound.vibrations, [120, 120])

## CHECK: 7
func test_cr_1179_main_dead_initial_state() -> void:
	var level = _make_level()
	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	
	m.session.board.apply("mark", 0, 0)
	m.session.board.apply("mark", 1, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	
	add_child_autofree(m)
	await wait_frames(2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	
	m.session.tap(1, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])

## CHECK: 8
func test_cr_1179_main_dead_tutorial() -> void:
	var level = _make_level()
	var m = await _make_main([level])
	
	m.start_tutorial()
	m.tutorial.session.tap(0, 2)
	assert_eq(m.sound.played.count("dead"), 0)
	assert_eq(m.sound.vibrations, [])
	
	m.end_tutorial()
	m.session.tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.sound.played[-1], "dead")
	assert_eq(m.sound.vibrations, [120])
== 既存のテストの書き直し
== 終わり
