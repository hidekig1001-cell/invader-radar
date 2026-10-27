extends GutTest
# 区域の番号が飛んでいても全部の区域を見る直しの確かめる項目を GUT にした見本（req_region_gaps.txt の項目 1〜3 と同じ順）。
# main 9193cdf で流す。直しなしでは 3 関数とも落ち、try_region_gaps_patch.py を当てた写しでは通る見込み（このクラウドには Godot が無く、流してはいない）。


func _gap_level():
	var Level = load("res://game/level.gd")
	var level = Level.new()
	assert_eq(level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}), true)
	return level


## CHECK: 1
func test_parse_renumbers_regions() -> void:
	var level = _gap_level()
	assert_eq(level.region_count(), 4)
	assert_eq(level.region_at(0, 0), 0)
	assert_eq(level.region_at(2, 0), 1)
	assert_eq(level.region_at(0, 2), 2)
	assert_eq(level.region_at(3, 3), 3)
	assert_eq(level.to_dict()["regions"], [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]])


## CHECK: 2
func test_dead_marks_sees_last_region() -> void:
	var level = _gap_level()
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var b = BS.new(4, 4)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	assert_eq(Rules.dead_marks(b, level), [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)])


## CHECK: 3
func test_filled_lines_sees_last_region() -> void:
	var level = _gap_level()
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	assert_eq(Rules.filled_lines(b, level), [{"kind": "region", "index": 3, "cells": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]}])
