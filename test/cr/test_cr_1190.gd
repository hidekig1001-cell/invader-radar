extends GutTest

const Level = preload("res://game/level.gd")
const Rules = preload("res://core/rules.gd")
const BS = preload("res://core/board_state.gd")


## CHECK: 1
func test_cr_1190_remap_region_indices() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	assert_eq(level.region_count(), 4)
	assert_eq(level.region_at(0, 0), 0)
	assert_eq(level.region_at(2, 0), 1)
	assert_eq(level.region_at(0, 2), 2)
	assert_eq(level.region_at(3, 3), 3)
	var d = level.to_dict()
	assert_eq(d["regions"], [
		[0, 0, 1, 1],
		[0, 0, 1, 1],
		[2, 2, 3, 3],
		[2, 2, 3, 3]
	])


## CHECK: 2
func test_cr_1190_dead_marks_with_remap() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	var b = BS.new(4, 4)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	var marks = Rules.dead_marks(b, level)
	assert_eq(marks.size(), 4)
	# The order in the CR is [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]
	# We check if the array contains these elements. Since order might vary by implementation details of iteration,
	# but CR says "is [ ... ]", we assume strict order or at least presence.
	# Given the instruction "write the expected value in the order written in the CR", we compare directly.
	assert_eq(marks, [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)])


## CHECK: 3
func test_cr_1190_filled_lines_with_remap() -> void:
	var level = Level.new()
	var data = {
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 2, 2],
			[0, 0, 2, 2],
			[5, 5, 7, 7],
			[5, 5, 7, 7]
		]
	}
	assert_true(level.parse(data))
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 2, 2)
	b.apply("mark", 3, 2)
	b.apply("mark", 2, 3)
	assert_eq(Rules.filled_lines(b, level), [{"kind": "region", "index": 3, "cells": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]}])

