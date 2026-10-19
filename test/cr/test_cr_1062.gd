extends GutTest

const Session = preload("res://game/session.gd")
const LevelPack = preload("res://game/level_pack.gd")


## CHECK: 1
func test_session_load_default_levels_placeholder_regions() -> void:
	var session = Session.new()
	var levels = session.levels
	assert_eq(levels.size(), 25)
	for i in range(10, 15):
		var lv = levels[i]
		assert_not_null(lv)
		assert_eq(lv.id, i + 1)
		assert_eq(lv.width, 6)
		assert_eq(lv.height, 6)
		assert_eq(lv.target, 6)
		var rows = lv.regions.to_rows()
		assert_eq(rows.size(), 6)
		assert_eq(rows[0], "000000")
		assert_eq(rows[1], "111111")
		assert_eq(rows[2], "222222")
		assert_eq(rows[3], "333333")
		assert_eq(rows[4], "444444")
		assert_eq(rows[5], "555555")
	for i in range(15, 25):
		var lv = levels[i]
		assert_not_null(lv)
		assert_eq(lv.id, i + 1)
		assert_eq(lv.width, 7)
		assert_eq(lv.height, 7)
		assert_eq(lv.target, 7)
		var rows = lv.regions.to_rows()
		assert_eq(rows.size(), 7)
		assert_eq(rows[0], "0000000")
		assert_eq(rows[1], "1111111")
		assert_eq(rows[2], "2222222")
		assert_eq(rows[3], "3333333")
		assert_eq(rows[4], "4444444")
		assert_eq(rows[5], "5555555")
		assert_eq(rows[6], "6666666")


## CHECK: 2
func test_fixed_level_dicts_size_and_ids() -> void:
	var dicts = LevelPack.fixed_level_dicts()
	assert_eq(dicts.size(), 10)
	assert_eq(dicts[0].get("id"), 1)
	assert_eq(dicts[9].get("id"), 10)
