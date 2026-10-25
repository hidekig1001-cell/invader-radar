extends GutTest

const Rules = preload("res://core/rules.gd")
const Level = preload("res://game/level.gd")
const BS = preload("res://core/board_state.gd")

## CHECK: 1
func test_cr_1166_check_1() -> void:
	var l = Level.new()
	l.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"radar": [[2, 1, 1]]
	})

	var b = BS.new(4, 4)
	b.apply("place", 2, 1)
	var conflicts = Rules.conflicts(b, l)
	assert_eq(conflicts, [Vector2i(2, 1)])

	var b2 = BS.new(4, 4)
	b2.apply("place", 0, 0)
	var conflicts2 = Rules.conflicts(b2, l)
	assert_eq(conflicts2, [])
