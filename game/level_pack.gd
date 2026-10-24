extends RefCounted

const ASTEROID_CELLS := {6: [[2, 2], [4, 0]], 7: [[4, 0], [1, 3]], 8: [[0, 0], [2, 4]], 9: [[0, 0], [3, 3]], 10: [[0, 0], [2, 4]]}
const RADAR_CELLS := {6: [[1, 0, 2], [3, 3, 2], [0, 4, 1]], 7: [[0, 4, 0], [2, 1, 2], [3, 2, 2]], 8: [[1, 1, 2], [3, 2, 2], [4, 4, 1]], 9: [[0, 4, 0], [2, 1, 2], [2, 2, 2]], 10: [[1, 1, 2], [3, 3, 2], [4, 0, 1]]}
const GENERATED_SPECS := [
	[11, 5, 1, 4, 3], [12, 5, 2, 4, 3], [13, 5, 3, 4, 3], [14, 5, 4, 3, 2], [15, 5, 5, 3, 2],
	[16, 5, 6, 3, 2], [17, 5, 7, 2, 2], [18, 5, 8, 2, 1], [19, 5, 9, 2, 1], [20, 5, 10, 1, 1],
	[21, 6, 1, 5, 3], [22, 6, 2, 5, 3], [23, 6, 3, 5, 3], [24, 6, 4, 5, 3], [25, 6, 5, 4, 3],
	[26, 6, 6, 4, 3], [27, 6, 7, 4, 2], [28, 6, 8, 4, 2], [29, 6, 9, 3, 2], [30, 6, 10, 3, 2],
	[31, 6, 11, 3, 2], [32, 6, 12, 3, 2], [33, 6, 13, 2, 2], [34, 6, 14, 2, 2], [35, 6, 15, 2, 1],
	[36, 6, 16, 2, 1], [37, 6, 17, 2, 1], [38, 6, 18, 1, 1], [39, 6, 19, 1, 1], [40, 6, 20, 1, 1],
	[41, 7, 1, 6, 4], [42, 7, 2, 6, 4], [43, 7, 3, 6, 4], [44, 7, 4, 6, 4], [45, 7, 5, 6, 4],
	[46, 7, 6, 5, 4], [47, 7, 7, 5, 3], [48, 7, 8, 5, 3], [49, 7, 9, 5, 3], [50, 7, 10, 5, 3],
	[51, 7, 11, 4, 3], [52, 7, 12, 4, 3], [53, 7, 13, 4, 3], [54, 7, 14, 4, 3], [55, 7, 15, 4, 2],
	[56, 7, 16, 3, 2], [57, 7, 17, 3, 2], [58, 7, 18, 3, 2], [59, 7, 19, 3, 2], [60, 7, 20, 3, 2],
	[61, 7, 21, 3, 2], [62, 7, 22, 3, 2], [63, 7, 23, 2, 2], [64, 7, 24, 2, 2], [65, 7, 25, 2, 1],
	[66, 7, 26, 2, 1], [67, 7, 27, 2, 1], [68, 7, 28, 2, 1], [69, 7, 29, 2, 1], [70, 7, 30, 2, 1],
	[71, 8, 1, 7, 4], [72, 8, 2, 7, 4], [73, 8, 3, 7, 4], [74, 8, 4, 7, 4], [75, 8, 5, 7, 4],
	[76, 8, 6, 6, 4], [77, 8, 7, 6, 4], [78, 8, 8, 6, 4], [79, 8, 9, 6, 3], [80, 8, 10, 6, 3],
	[81, 8, 11, 5, 3], [82, 8, 12, 5, 3], [83, 8, 13, 5, 3], [84, 8, 14, 5, 3], [85, 8, 15, 5, 3],
	[86, 8, 16, 5, 3], [87, 8, 17, 5, 2], [88, 8, 18, 5, 2], [89, 8, 19, 5, 2], [90, 8, 20, 5, 2],
	[91, 8, 21, 4, 2], [92, 8, 22, 4, 2], [93, 8, 23, 4, 2], [94, 8, 24, 4, 2], [95, 8, 25, 4, 2],
	[96, 8, 26, 4, 2], [97, 8, 27, 4, 2], [98, 8, 28, 4, 2], [99, 8, 29, 4, 2], [100, 8, 30, 4, 2]
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
			var radar_count = spec[3]
			var asteroid_count = spec[4]
			var d = LevelMaker.make_level(w, w, seed, radar_count, asteroid_count)
			d["id"] = id
			generated_cache.append(d)
	return generated_cache.duplicate(true)

static func level_dicts() -> Array:
	var fixed = fixed_level_dicts()
	var gen = generated_levels()
	fixed.append_array(gen)
	return fixed
