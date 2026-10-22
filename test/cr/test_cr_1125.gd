extends GutTest

const Prefetch = preload("res://game/level_prefetch.gd")
const Maker = preload("res://game/level_maker.gd")
const Lv = preload("res://game/level.gd")
const Solv = preload("res://core/solver.gd")


## CHECK: 1
func test_build_returns_level_and_solution() -> void:
	var made = Prefetch.build(6, 7, 3, 1)
	var expected = Maker.make_level(6, 6, 7, 3, 1)
	assert_eq(made["level"]["regions"], expected["regions"])
	assert_eq(made["level"]["radar"], expected["radar"])
	var lv = Lv.new()
	lv.parse(expected)
	assert_eq(made["solution"], Solv.solutions(lv, 1)[0])
	var small = Prefetch.build(5, 7, 1, 1)
	assert_eq(small["solution"].size(), 0)


## CHECK: 2
func test_start_take_returns_result() -> void:
	var p = Prefetch.new()
	assert_true(p.take(21).is_empty())
	p.start(21, 6, 7, 3, 1)
	var got = p.take(21)
	var expected = Prefetch.build(6, 7, 3, 1)
	assert_eq(got["level"]["regions"], expected["level"]["regions"])
	assert_eq(got["solution"], expected["solution"])
	assert_true(p.take(21).is_empty())


## CHECK: 3
func test_start_take_index_mismatch_and_overwrite() -> void:
	var p = Prefetch.new()
	p.start(22, 6, 8, 3, 1)
	assert_true(p.take(23).is_empty())
	assert_true(p.take(22).is_empty())
	p.start(24, 6, 9, 3, 1)
	p.start(25, 6, 10, 3, 1)
	var got = p.take(25)
	var expected = Prefetch.build(6, 10, 3, 1)
	assert_eq(got["level"]["regions"], expected["level"]["regions"])
