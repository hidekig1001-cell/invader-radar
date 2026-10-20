extends RefCounted


static func practice_level() -> Dictionary:
	return {
		"id": 0,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 0, 0],
			[0, 0, 0, 2],
			[3, 1, 1, 1],
			[1, 1, 1, 1]
		]
	}


static func steps() -> Array:
	return [
		{
			"text": "EACH COLOR NEEDS ONE PIECE.\nDOUBLE TAP THE GREEN CELL.",
			"highlight": [Vector2i(3, 1)],
			"wait": {"kind": "double_tap", "cell": Vector2i(3, 1)}
		},
		{
			"text": "ONE PIECE PER ROW AND COLUMN, TOO.\nMARK AN X ON THE 6 CELLS.",
			"highlight": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 3)],
			"wait": {"kind": "mark", "cells": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 3)]}
		},
		{
			"text": "PIECES CANNOT TOUCH DIAGONALLY EITHER.\nMARK AN X ON EACH DIAGONAL CELL.",
			"highlight": mark_cells(),
			"wait": {"kind": "mark"}
		},
		{
			"text": "THE PURPLE COLOR HAS ONLY ONE CELL.\nDOUBLE TAP IT.",
			"highlight": [Vector2i(0, 2)],
			"wait": {"kind": "double_tap", "cell": Vector2i(0, 2)}
		},
		{
			"text": "NOW PLACE THE LAST TWO PIECES.",
			"highlight": [],
			"wait": {"kind": "solved"}
		},
		{
			"text": "WELL DONE! YOU ARE READY.\nTAP TO START.",
			"highlight": [],
			"wait": {"kind": "next"}
		}
	]


static func apply_language(lang_code: String, step_index: int) -> String:
	if lang_code == "ja":
		match step_index:
			0:
				return "各色に駒を 1 つ置く。\n緑のマスをダブルタップ"
			1:
				return "各行・各列にも 1 つ。\n6 つのマスに × を付ける"
			2:
				return "斜めにも隣り合えない。\n斜めのマスに × を付ける"
			3:
				return "紫は 1 マスだけ。\nそこをダブルタップ"
			4:
				return "残りの 2 つの駒を置く。"
			5:
				return "よくできました！\nタップで開始"
			_:
				return ""
	else:
		var all_steps = steps()
		if step_index >= 0 and step_index < all_steps.size():
			return all_steps[step_index]["text"]
		return ""


static func diagonal_cells(cell: Vector2i, width: int, height: int) -> Array:
	var result = []
	for dx in [-1, 1]:
		for dy in [-1, 1]:
			var x = cell.x + dx
			var y = cell.y + dy
			if x >= 0 and x < width and y >= 0 and y < height:
				result.append(Vector2i(x, y))
	return result


static func mark_cells() -> Array:
	return [Vector2i(2, 0), Vector2i(2, 2)]
