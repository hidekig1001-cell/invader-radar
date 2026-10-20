extends GutTest

const LM = preload("res://game/level_maker.gd")

## CHECK: 1
func test_make_level_greedy_basic_unique_and_minimal_radar() -> void:
	var d = LM.make_level_greedy(8, 1, 6)
	assert_false(d.is_empty())
	assert_eq(d["width"], 8)
	assert_true(d.has("radar"))
	var radar_size = d["radar"].size()
	assert_true(radar_size >= 1 and radar_size <= 6)
	assert_true(LM.has_unique_solution(d))
	
	# Check that removing the last radar breaks uniqueness (greedy stops when unique)
	var e = d.duplicate(true)
	e["radar"].pop_back()
	assert_false(LM.has_unique_solution(e))

## CHECK: 2
func test_make_level_greedy_deterministic() -> void:
	var d1 = LM.make_level_greedy(8, 3, 6)
	var d2 = LM.make_level_greedy(8, 3, 6)
	assert_false(d1.is_empty())
	assert_false(d2.is_empty())
	assert_eq(d1, d2)

## CHECK: 3
func test_make_level_greedy_with_asteroids() -> void:
	var d = LM.make_level_greedy(9, 4, 8, 2)
	assert_false(d.is_empty())
	assert_eq(d["width"], 9)
	assert_true(d.has("asteroids"))
	assert_eq(d["asteroids"].size(), 2)
	assert_true(d.has("radar"))
	var radar_size = d["radar"].size()
	assert_true(radar_size >= 1 and radar_size <= 8)
	assert_true(LM.has_unique_solution(d))
	
	# Check that no radar cell overlaps with an asteroid cell
	for r in d["radar"]:
		var rx = r[0]
		var ry = r[1]
		for a in d["asteroids"]:
			var ax = a[0]
			var ay = a[1]
			assert_ne([rx, ry], [ax, ay])
			
	# Check that removing the last radar breaks uniqueness
	var e = d.duplicate(true)
	e["radar"].pop_back()
	assert_false(LM.has_unique_solution(e))
