# game/level.gd と data/levels/*.json の単体テスト。
extends GutTest

const Level = preload("res://game/level.gd")
const Session = preload("res://game/session.gd")

const SAMPLE := {"id": 9, "width": 3, "height": 2, "target": 2,
	"regions": [[0, 0, 1], [2, 1, 1]], "asteroids": [[1, 1]], "radar": [[0, 1]]}


func test_parse_sample() -> void:
	var lv = Level.new()
	assert_true(lv.parse(SAMPLE))
	assert_eq(lv.id, 9)
	assert_eq(lv.width, 3)
	assert_eq(lv.height, 2)
	assert_eq(lv.target, 2)
	assert_eq(lv.region_at(2, 0), 1)
	assert_eq(lv.region_at(0, 1), 2)
	assert_eq(lv.asteroids, [Vector2i(1, 1)])
	assert_eq(lv.radar, [Vector2i(0, 1)])
	assert_eq(lv.region_count(), 3)


func test_round_trip_through_json_text() -> void:
	var lv = Level.new()
	lv.parse(SAMPLE)
	var again = Level.new()
	assert_true(again.parse_json(lv.to_json()))
	assert_eq(again.to_dict(), lv.to_dict())


func test_rejects_bad_shapes() -> void:
	var lv = Level.new()
	assert_false(lv.parse({}))
	assert_false(lv.parse({"width": 3, "height": 2, "target": 2, "regions": [[0, 0, 1]]}), "行の数が合わない")
	assert_false(lv.parse({"width": 3, "height": 1, "target": 2, "regions": [[0, 0]]}), "列の数が合わない")
	assert_false(lv.parse({"width": 2, "height": 1, "target": 1, "regions": [[0, 1]], "asteroids": [[5, 5]]}), "盤の外")
	assert_false(lv.parse_json("not json"))
	assert_eq(lv.width, 0, "失敗したら中身は変えない")


func test_load_missing_file() -> void:
	var lv = Level.new()
	assert_false(lv.load_file("res://data/levels/nope.json"))


func test_default_levels_are_three_4x4_levels() -> void:
	var levels: Array = Session.load_default_levels()
	assert_eq(levels.size(), 3)
	for lv in levels:
		assert_eq(lv.width, 4)
		assert_eq(lv.height, 4)
		assert_eq(lv.target, 4)
		assert_eq(lv.region_count(), 4, "区域は 4 つ")


func test_default_levels_have_distinct_ids_and_valid_regions() -> void:
	var levels: Array = Session.load_default_levels()
	assert_eq(levels.size(), 3)
	var ids := {}
	for lv in levels:
		ids[lv.id] = true
		for y in range(lv.height):
			for x in range(lv.width):
				var r: int = lv.region_at(x, y)
				assert_true(r >= 0 and r < 4, "区域の番号は 0〜3")
	assert_eq(ids.size(), 3)
