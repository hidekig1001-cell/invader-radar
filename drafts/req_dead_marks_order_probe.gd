extends GutTest
# Rules.dead_marks の判定の順をそろえる直しの確かめる項目を GUT にした見本（req_dead_marks_order.txt の項目 1〜3 と同じ順）。

const REGIONS := [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]


func _level(extra: Dictionary):
	var Level = load("res://game/level.gd")
	var level = Level.new()
	var d = {"width": 4, "height": 4, "target": 4, "regions": REGIONS}
	d.merge(extra)
	level.parse(d)
	return level


## CHECK: 1
func test_alien_on_radar_not_counted_in_row() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level({"radar": [[0, 0, 1]]})
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	assert_eq(Rules.dead_marks(b, level), [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


## CHECK: 2
func test_alien_on_asteroid_not_counted_but_normal_alien_counts() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level({"asteroids": [[3, 3]]})
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	assert_eq(Rules.dead_marks(b, level), [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	b.apply("place", 1, 3)
	assert_eq(Rules.dead_marks(b, level), [])


## CHECK: 3
func test_alien_on_radar_not_counted_in_region_and_column() -> void:
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	var level = _level({"radar": [[0, 0, 1]]})
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	assert_eq(Rules.dead_marks(b, level), [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	assert_eq(Rules.dead_marks(b, level), [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)])
