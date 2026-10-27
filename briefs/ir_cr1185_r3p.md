# クラウドへの依頼: InvaderRadar改修1185 の R3'（テストを読む）（1 回目、2026-10-27 14:4x、Invader Radar30）

依頼と CR は branch review/cr1185-r0p の briefs/ir_cr1185_r0p.md（R0' は OK、results/cr1185_r0p.md）。main は 61433f2（v1.93-cr1184）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183、値まるごとの assert_eq にさせる）。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜4 の手順と期待値（flashes・flash_cells の値まるごと、flash_alpha の 0.5・0.25 は誤差 0.001・0.3 秒後は 0.0、組の並び 行 0 → 区域 0、dead の手で []）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手（tap・double_tap・apply）や表明が無いか。
2. 期待値が今の main（61433f2）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1185-r3p のファイル results/cr1185_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1438-CR-1185
== tests/test_cr_1185.gd
extends GutTest

const BoardViewScript = preload("res://scenes/board_view.gd")
const LevelScript = preload("res://game/level.gd")
const MainScene = preload("res://scenes/main.tscn")
const SessionScript = preload("res://game/session.gd")


## CHECK: 1
func test_flash_lines_and_alpha() -> void:
	var bv = BoardViewScript.new()
	add_child_autofree(bv)

	# Initial state
	assert_eq(bv.flashes, [])
	assert_eq(bv.flash_alpha(0.0), 0.0)

	# Trigger flash
	var lines = [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]
	bv.flash_lines(lines)

	# Check state after trigger
	assert_eq(bv.flashes, [[Vector2i(0, 0), Vector2i(1, 0)]])
	assert_eq(bv.flash_cells, [Vector2i(0, 0), Vector2i(1, 0)])

	# Check alpha values
	var start_time = bv.flash_start
	assert_almost_eq(bv.flash_alpha(start_time), 0.5, 0.001)
	assert_almost_eq(bv.flash_alpha(start_time + 0.15), 0.25, 0.001)
	assert_almost_eq(bv.flash_alpha(start_time + 0.3), 0.0, 0.001)


## CHECK: 2
func test_main_flash_on_line_completion() -> void:
	var level = LevelScript.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})

	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)

	# Place pieces and marks to complete row 0
	m.session.double_tap(0, 0) # Place piece
	m.session.tap(1, 0)        # Mark
	m.session.tap(2, 0)        # Mark
	
	# No flash yet because line is not complete (cell 3,0 is empty)
	assert_eq(m.board_view.flashes, [])

	m.session.tap(3, 0)        # Mark completes row 0

	# Flash should occur for row 0
	var expected_flashes = [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]]
	assert_eq(m.board_view.flashes, expected_flashes)


## CHECK: 3
func test_main_flash_multiple_lines_order_and_unique_cells() -> void:
	var level = LevelScript.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})

	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	
	# Pre-fill board to set up the scenario where one tap completes two lines
	# Row 0 needs (1,0) to be marked. Cells (0,0), (2,0), (3,0) are already marked/placed?
	# CR says: apply("place", 0, 0), apply("mark", 2, 0), apply("mark", 3, 0), apply("mark", 0, 1), apply("mark", 1, 1)
	# Then tap(1, 0).
	
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	
	add_child_autofree(m)
	await wait_frames(2)

	# Tap (1,0) to complete Row 0 and Region 0
	m.session.tap(1, 0)

	# Expected flashes: Row 0 first, then Region 0
	var expected_flashes = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], # Row 0
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]  # Region 0
	]
	assert_eq(m.board_view.flashes, expected_flashes)

	# Expected flash_cells: Unique cells from both lines
	var expected_flash_cells = [
		Vector2i(0, 0), 
		Vector2i(1, 0), 
		Vector2i(2, 0), 
		Vector2i(3, 0), 
		Vector2i(0, 1), 
		Vector2i(1, 1)
	]
	assert_eq(m.board_view.flash_cells, expected_flash_cells)


## CHECK: 4
func test_main_no_flash_on_dead_line_then_flash_on_region() -> void:
	var level = LevelScript.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})

	var m = MainScene.instantiate()
	m.session = SessionScript.new([level])
	add_child_autofree(m)
	await wait_frames(2)

	# Setup: 
	# double_tap(0,0) -> Piece at (0,0)
	# tap(1,0), tap(2,0) -> Marks at (1,0), (2,0)
	# tap(3,1), tap(3,2), tap(3,3) -> Marks in Col 3
	# tap(3,0) -> Completes Row 0 AND Col 3. 
	# Col 3 is all marks (dead). So this move is "dead". No flash expected.
	
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 1)
	m.session.tap(3, 2)
	m.session.tap(3, 3)
	m.session.tap(3, 0)

	assert_eq(m.board_view.flashes, [])

	# Next moves:
	# tap(0,1), tap(1,1) -> Completes Region 0 (cells 0,0; 1,0; 0,1; 1,1).
	# (0,0) is piece, (1,0) is mark, (0,1) becomes mark, (1,1) becomes mark.
	# This completes Region 0. Flash expected.
	
	m.session.tap(0, 1)
	m.session.tap(1, 1)

	var expected_flashes = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
	]
	assert_eq(m.board_view.flashes, expected_flashes)
== 既存のテストの書き直し
== 終わり
