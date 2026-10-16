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
			"text": "ONE PIECE PER ROW AND COLUMN, TOO.\nTAP TO CONTINUE.",
			"highlight": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 3)],
			"wait": {"kind": "next"}
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
