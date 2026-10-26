extends GutTest
# 手触り 2 本目・規則（Rules.filled_lines）の確かめる項目を GUT にした見本（req_line_rules.txt の項目 1〜5 と同じ順）。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _level(extra: Dictionary = {}):
	var Level = load("res://game/level.gd")
	var level = Level.new()
	var d = {"width": 4, "height": 4, "target": 4, "regions": REGIONS}
	d.merge(extra)
	level.parse(d)
	return level


func _row0() -> Dictionary:
	return {"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}


## CHECK: 1
func test_row_filled_with_one_alien() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level()
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	assert_eq(Rules.filled_lines(b, level), [])
	b.apply("mark", 3, 0)
	assert_eq(Rules.filled_lines(b, level), [_row0()])


## CHECK: 2
func test_two_aliens_or_no_alien_not_filled() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level()
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("place", 2, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 3, 0)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	assert_eq(Rules.filled_lines(b, level), [])
	b.apply("mark", 2, 0)
	assert_eq(Rules.filled_lines(b, level), [_row0()])


## CHECK: 3
func test_red_alien_not_filled() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level()
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("place", 0, 2)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	assert_eq(Rules.filled_lines(b, level), [])
	b.apply("clear", 0, 2)
	assert_eq(Rules.filled_lines(b, level), [_row0()])


## CHECK: 4
func test_order_row_column_region() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level()
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	var region0 = {"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}
	assert_eq(Rules.filled_lines(b, level), [region0])
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	var column0 = {"kind": "column", "index": 0, "cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]}
	assert_eq(Rules.filled_lines(b, level), [_row0(), column0, region0])


## CHECK: 5
func test_asteroid_and_radar_cells_skipped() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level({"asteroids": [[3, 0]], "radar": [[2, 0, 1]]})
	var b = BS.new(4, 4)
	b.apply("mark", 0, 0)
	b.apply("place", 1, 0)
	var row0 = {"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}
	assert_eq(Rules.filled_lines(b, level), [row0])
