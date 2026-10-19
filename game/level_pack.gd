extends RefCounted

const ASTEROID_CELLS := {6: [[2, 2], [4, 0]], 7: [[4, 0], [1, 3]], 8: [[0, 0], [2, 4]], 9: [[0, 0], [3, 3]], 10: [[0, 0], [2, 4]]}
const RADAR_CELLS := {6: [[1, 0, 2], [3, 3, 2], [0, 4, 1]], 7: [[0, 4, 0], [2, 1, 2], [3, 2, 2]], 8: [[1, 1, 2], [3, 2, 2], [4, 4, 1]], 9: [[0, 4, 0], [2, 1, 2], [2, 2, 2]], 10: [[1, 1, 2], [3, 3, 2], [4, 0, 1]]}
const GENERATED_SPECS := [
	[11, 6, 1], [12, 6, 2], [13, 6, 3], [14, 6, 4], [15, 6, 5],
	[16, 7, 1], [17, 7, 2], [18, 7, 3], [19, 7, 4], [20, 7, 5],
	[21, 7, 6], [22, 7, 7], [23, 7, 8], [24, 7, 9], [25, 7, 10],
	[26, 8, 1], [27, 8, 2], [28, 8, 3], [29, 8, 4], [30, 8, 5],
	[31, 8, 6], [32, 8, 7], [33, 8, 8], [34, 8, 9], [35, 8, 10]
]

static var generated_cache: Array = []

static func with_asteroids(dicts: Array) -> Array:
	var result: Array = []
	for d in dicts:
		var id = d.get("id", -1)
		if ASTEROID_CELLS.has(id) or RADAR_CELLS.has(id):
			var new_d = d.duplicate(true)
			if ASTEROID_CELLS.has(id):
				new_d["asteroids"] = ASTEROID_CELLS[id]
			if RADAR_CELLS.has(id):
				new_d["radar"] = RADAR_CELLS[id]
			result.append(new_d)
		else:
			result.append(d)
	return result

static func fixed_level_dicts() -> Array:
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
	return with_asteroids(base_levels)

static func generated_levels() -> Array:
	if generated_cache.is_empty():
		var LevelMaker = preload("res://game/level_maker.gd")
		for spec in GENERATED_SPECS:
			var id = spec[0]
			var w = spec[1]
			var seed = spec[2]
			var d = LevelMaker.make_level(w, w, seed)
			d["id"] = id
			generated_cache.append(d)
	return generated_cache.duplicate(true)

static func level_dicts() -> Array:
	var fixed = fixed_level_dicts()
	var gen = generated_levels()
	fixed.append_array(gen)
	return fixed
