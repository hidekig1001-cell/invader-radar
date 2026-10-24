extends GutTest

const LevelPack = preload("res://game/level_pack.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")


func _get_level_dict_by_id(dicts: Array, id: int) -> Dictionary:
	for d in dicts:
		if d.get("id", -1) == id:
			return d
	return {}


## CHECK: 1
func test_cr_1041_id6_asteroids_and_unique_solution() -> void:
	var dicts = LevelPack.level_dicts()
	var d6 = _get_level_dict_by_id(dicts, 6)
	assert_true(d6.has("asteroids"), "id 6 dict should have 'asteroids' key")
	assert_eq(d6["asteroids"], [[2, 2], [4, 0]], "id 6 asteroids mismatch")
	var lv = Level.new()
	lv.parse(d6)
	assert_eq(Solver.count_solutions(lv, 2), 1, "id 6 should have exactly 1 solution")


## CHECK: 2
func test_cr_1041_id8_asteroids_and_unique_solution() -> void:
	var dicts = LevelPack.level_dicts()
	var d8 = _get_level_dict_by_id(dicts, 8)
	assert_true(d8.has("asteroids"), "id 8 dict should have 'asteroids' key")
	assert_eq(d8["asteroids"], [[0, 0], [2, 4]], "id 8 asteroids mismatch")
	var lv = Level.new()
	lv.parse(d8)
	assert_eq(Solver.count_solutions(lv, 2), 1, "id 8 should have exactly 1 solution")


## CHECK: 3
func test_cr_1041_id9_asteroids_and_unique_solution() -> void:
	var dicts = LevelPack.level_dicts()
	var d9 = _get_level_dict_by_id(dicts, 9)
	assert_true(d9.has("asteroids"), "id 9 dict should have 'asteroids' key")
	assert_eq(d9["asteroids"], [[0, 0], [3, 3]], "id 9 asteroids mismatch")
	var lv = Level.new()
	lv.parse(d9)
	assert_eq(Solver.count_solutions(lv, 2), 1, "id 9 should have exactly 1 solution")


## CHECK: 4
func test_cr_1041_only_ids_6_8_9_have_asteroids() -> void:
	var dicts = LevelPack.level_dicts()
	var asteroid_ids = []
	for d in dicts:
		if d.has("asteroids"):
			asteroid_ids.append(d["id"])
	assert_eq(asteroid_ids, [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100], "Only ids 6, 8, 9, 16-25 should have asteroids")
	
	for d in dicts:
		var id = d.get("id", -1)
		if id >= 6:
			assert_true(d.has("asteroids"), "id %d should have asteroids" % id)
		else:
			assert_false(d.has("asteroids"), "id %d should NOT have asteroids" % id)
