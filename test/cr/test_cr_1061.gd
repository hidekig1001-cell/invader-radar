extends GutTest

const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")
const LevelPack = preload("res://game/level_pack.gd")


func test_uses_default_levels_flag() -> void:
	## CHECK: 1
	var s_empty = Session.new()
	assert_true(s_empty.uses_default_levels)

	var lv = Level.new()
	lv.parse({"id": 1, "width": 4, "height": 4})
	var s_with_level = Session.new([lv])
	assert_false(s_with_level.uses_default_levels)


func test_restart_keeps_generated_level_for_default_levels() -> void:
	## CHECK: 2
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	var a = s.level.regions.to_rows()

	s.rng.seed = 2
	s.restart_level()
	assert_eq(s.level.regions.to_rows(), a)
	assert_eq(s.level.id, 14)


func test_restore_uses_pack_level_when_not_default() -> void:
	## CHECK: 3
	var levels = Session.load_default_levels()
	var s = Session.new(levels)
	s.rng.seed = 1
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})

	var dicts = LevelPack.level_dicts()
	var expected_lv = Level.new()
	expected_lv.parse(dicts[13])
	assert_eq(s.level.regions.to_rows(), expected_lv.regions.to_rows())


func test_restart_keeps_pack_level_when_not_default() -> void:
	## CHECK: 4
	var levels = Session.load_default_levels()
	var s = Session.new(levels)
	s.rng.seed = 1
	s.restore_dict({"level_index": 13, "score": 0, "hints": 3})
	var expected_rows = s.level.regions.to_rows()

	s.restart_level()
	assert_eq(s.level.regions.to_rows(), expected_rows)
	assert_eq(s.level.id, 14)
	assert_eq(s.moves, 0)
	assert_eq(s.status, "playing")
