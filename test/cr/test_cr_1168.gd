extends GutTest

const Level = preload("res://game/level.gd")
const Deduce = preload("res://core/deduce.gd")


## CHECK: 1
func test_analyze_level_1() -> void:
	var l = Level.new()
	l.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var result = Deduce.analyze(l)
	assert_eq(result["stuck"], 0)
	assert_eq(result["key_move"], false)
	assert_eq(result["max_cascade"], 0)


## CHECK: 2
func test_analyze_level_2() -> void:
	var l = Level.new()
	l.parse({"id": 2, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]})
	var result = Deduce.analyze(l)
	assert_eq(result["stuck"], 1)
	assert_eq(result["key_move"], true)
	assert_eq(result["max_cascade"], 3)


## CHECK: 3
func test_analyze_level_3_radar() -> void:
	var l = Level.new()
	l.parse({"id": 3, "width": 4, "height": 4, "target": 4, "radar": [[3, 3, 1]], "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var result = Deduce.analyze(l)
	assert_eq(result["stuck"], 0)
	assert_eq(result["key_move"], false)
	assert_eq(result["max_cascade"], 0)


## CHECK: 4
func test_analyze_level_3_eliminate() -> void:
	var l = Level.new()
	l.parse({"id": 3, "width": 4, "height": 4, "target": 4, "regions": [[1, 0, 0, 0], [1, 1, 3, 3], [1, 1, 2, 2], [1, 1, 2, 2]]})
	var result = Deduce.analyze(l)
	assert_eq(result["stuck"], 0)
	assert_eq(result["key_move"], false)
	assert_eq(result["max_cascade"], 0)
