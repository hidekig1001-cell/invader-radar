extends GutTest
# 手触り 2 本目・光（そろった組を短く光らせる）の確かめる項目を GUT にした見本（req_line_flash.txt の項目 1〜4 と同じ順）。
# 手触り 2 本目の規則と音が入った main で流す。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _new_main():
	var Level = load("res://game/level.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": REGIONS})
	var Main = load("res://scenes/main.tscn")
	var SessionScript = load("res://game/session.gd")
	var m = Main.instantiate()
	m.session = SessionScript.new([level])
	return m


## CHECK: 1
func test_flash_lines_and_alpha() -> void:
	var BV = load("res://scenes/board_view.gd")
	var bv = BV.new()
	add_child_autofree(bv)
	assert_eq(bv.flashes, [])
	assert_eq(bv.flash_alpha(0.0), 0.0)
	bv.flash_lines([{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}])
	assert_eq(bv.flashes, [[Vector2i(0, 0), Vector2i(1, 0)]])
	assert_eq(bv.flash_cells, [Vector2i(0, 0), Vector2i(1, 0)])
	assert_almost_eq(bv.flash_alpha(bv.flash_start), 0.5, 0.001)
	assert_almost_eq(bv.flash_alpha(bv.flash_start + 0.15), 0.25, 0.001)
	assert_eq(bv.flash_alpha(bv.flash_start + 0.3), 0.0)


## CHECK: 2
func test_main_flashes_on_line_hand() -> void:
	var m = _new_main()
	add_child_autofree(m)
	await wait_frames(2)
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	assert_eq(m.board_view.flashes, [])
	m.session.tap(3, 0)
	assert_eq(m.board_view.flashes, [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]])


## CHECK: 3
func test_main_flashes_two_groups_at_once() -> void:
	var m = _new_main()
	m.session.board.apply("place", 0, 0)
	m.session.board.apply("mark", 2, 0)
	m.session.board.apply("mark", 3, 0)
	m.session.board.apply("mark", 0, 1)
	m.session.board.apply("mark", 1, 1)
	add_child_autofree(m)
	await wait_frames(2)
	m.session.tap(1, 0)
	assert_eq(m.board_view.flashes, [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]])
	assert_eq(m.board_view.flash_cells, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1)])


## CHECK: 4
func test_no_flash_on_dead_hand() -> void:
	var m = _new_main()
	add_child_autofree(m)
	await wait_frames(2)
	m.session.double_tap(0, 0)
	m.session.tap(1, 0)
	m.session.tap(2, 0)
	m.session.tap(3, 1)
	m.session.tap(3, 2)
	m.session.tap(3, 3)
	m.session.tap(3, 0)
	assert_eq(m.board_view.flashes, [])
	m.session.tap(0, 1)
	m.session.tap(1, 1)
	assert_eq(m.board_view.flashes, [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]])
