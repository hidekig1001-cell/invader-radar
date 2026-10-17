extends RefCounted

const ASTEROID_CELLS := {6: [[2, 2], [4, 0]], 8: [[0, 0], [2, 4]], 9: [[0, 0], [3, 3]]}

static func with_asteroids(dicts: Array) -> Array:
	var result: Array = []
	for d in dicts:
		var id = d.get("id", -1)
		if ASTEROID_CELLS.has(id):
			var new_d = d.duplicate(true)
			new_d["asteroids"] = ASTEROID_CELLS[id]
			result.append(new_d)
		else:
			result.append(d)
	return result

static func generated_levels() -> Array:
	var LevelMaker = preload("res://game/level_maker.gd")
	var levels: Array = []
	for i in range(1, 4):
		var d = LevelMaker.make_level(6, 6, i)
		d["id"] = 10 + i
		levels.append(d)
	return levels

static func level_dicts() -> Array:
	var base_levels = [
		{
			"id": 1,
			"width": 4,
			"height": 4,
			"target": 4,
			"regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]
		},
		{
			"id": 2,
			"width": 4,
			"height": 4,
			"target": 4,
			"regions": [[0, 0, 2, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 3, 3, 1]]
		},
		{
			"id": 3,
			"width": 4,
			"height": 4,
			"target": 4,
			"regions": [[1, 0, 0, 0], [1, 1, 3, 3], [1, 1, 2, 2], [1, 1, 2, 2]]
		},
		{
			"id": 4,
			"width": 4,
			"height": 4,
			"target": 4,
			"regions": [[3, 3, 1, 1], [3, 3, 1, 1], [0, 0, 1, 1], [0, 2, 2, 1]]
		},
		{
			"id": 5,
			"width": 4,
			"height": 4,
			"target": 4,
			"regions": [[2, 2, 1, 1], [2, 0, 1, 3], [0, 0, 1, 3], [0, 0, 0, 3]]
		},
		{
			"id": 6,
			"width": 5,
			"height": 5,
			"target": 5,
			"regions": [[2, 2, 2, 2, 2], [0, 2, 2, 2, 2], [0, 2, 2, 2, 1], [0, 4, 4, 2, 3], [0, 4, 4, 3, 3]]
		},
		{
			"id": 7,
			"width": 5,
			"height": 5,
			"target": 5,
			"regions": [[2, 0, 0, 4, 4], [2, 2, 0, 1, 4], [2, 2, 0, 4, 4], [2, 2, 0, 0, 4], [3, 3, 3, 3, 3]]
		},
		{
			"id": 8,
			"width": 5,
			"height": 5,
			"target": 5,
			"regions": [[3, 3, 1, 2, 1], [3, 3, 1, 1, 1], [3, 3, 1, 1, 0], [3, 3, 1, 4, 0], [3, 4, 4, 4, 0]]
		},
		{
			"id": 9,
			"width": 5,
			"height": 5,
			"target": 5,
			"regions": [[0, 0, 0, 3, 3], [0, 0, 0, 3, 3], [2, 2, 2, 2, 2], [1, 1, 1, 1, 2], [1, 1, 1, 1, 4]]
		},
		{
			"id": 10,
			"width": 5,
			"height": 5,
			"target": 5,
			"regions": [[1, 2, 2, 2, 1], [1, 1, 1, 1, 1], [3, 0, 0, 0, 1], [3, 3, 0, 0, 1], [3, 3, 4, 4, 1]]
		}
	]
	var gen = generated_levels()
	base_levels.append_array(gen)
	return with_asteroids(base_levels)
