# core/grid.gd の単体テスト。
extends GutTest

const Grid = preload("res://core/grid.gd")


func test_size_and_fill() -> void:
	var g = Grid.new(4, 3, 7)
	assert_eq(g.width, 4)
	assert_eq(g.height, 3)
	assert_eq(g.get_cell(3, 2), 7)
	assert_eq(g.get_cell(0, 0), 7)


func test_in_bounds() -> void:
	var g = Grid.new(4, 4)
	assert_true(g.in_bounds(0, 0))
	assert_true(g.in_bounds(3, 3))
	assert_false(g.in_bounds(4, 0))
	assert_false(g.in_bounds(0, 4))
	assert_false(g.in_bounds(-1, 2))


func test_set_and_get() -> void:
	var g = Grid.new(4, 4)
	assert_true(g.set_cell(2, 1, 5))
	assert_eq(g.get_cell(2, 1), 5)
	assert_eq(g.get_cell(1, 2), 0, "x と y を取り違えない")


func test_out_of_bounds_get_and_set() -> void:
	var g = Grid.new(4, 4)
	assert_eq(g.get_cell(9, 9), -1)
	assert_eq(g.get_cell(-1, 0, 42), 42)
	assert_false(g.set_cell(4, 4, 1))
	assert_false(g.set_cell(-1, 0, 1))


func test_neighbors4() -> void:
	var g = Grid.new(4, 4)
	assert_eq(g.neighbors4(1, 1).size(), 4)
	assert_eq(g.neighbors4(0, 0).size(), 2)
	assert_eq(g.neighbors4(3, 1).size(), 3)
	assert_has(g.neighbors4(1, 1), Vector2i(1, 0))
	assert_does_not_have(g.neighbors4(1, 1), Vector2i(2, 2))


func test_neighbors8() -> void:
	var g = Grid.new(4, 4)
	assert_eq(g.neighbors8(1, 1).size(), 8)
	assert_eq(g.neighbors8(0, 0).size(), 3)
	assert_eq(g.neighbors8(3, 1).size(), 5)
	assert_has(g.neighbors8(1, 1), Vector2i(2, 2))
	assert_does_not_have(g.neighbors8(1, 1), Vector2i(1, 1))


func test_copy_is_independent() -> void:
	var g = Grid.new(3, 3)
	g.set_cell(1, 1, 4)
	var c = g.copy()
	assert_eq(c.get_cell(1, 1), 4)
	c.set_cell(1, 1, 9)
	assert_eq(g.get_cell(1, 1), 4)
	assert_eq(c.width, 3)


func test_to_rows() -> void:
	var g = Grid.new(3, 2)
	g.set_cell(0, 0, 1)
	g.set_cell(2, 1, 3)
	assert_eq(g.to_rows(), ["100", "003"])


func test_load_rows_round_trip() -> void:
	var g = Grid.new()
	g.load_rows(["0120", "3001"])
	assert_eq(g.width, 4)
	assert_eq(g.height, 2)
	assert_eq(g.get_cell(2, 0), 2)
	assert_eq(g.get_cell(0, 1), 3)
	assert_eq(g.to_rows(), ["0120", "3001"])
