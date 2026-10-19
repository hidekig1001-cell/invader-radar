extends GutTest

const LevelPack = preload("res://game/level_pack.gd")


## CHECK: 1
func test_generated_levels_cache_speed_and_independence() -> void:
	# 1回目
	var t0 = Time.get_ticks_msec()
	var first = LevelPack.generated_levels()
	var t1 = Time.get_ticks_msec()
	var duration_first = t1 - t0

	# 2回目
	var t2 = Time.get_ticks_msec()
	var second = LevelPack.generated_levels()
	var t3 = Time.get_ticks_msec()
	var duration_second = t3 - t2

	# 2回目は100ms未満
	assert_true(duration_second < 100, "Second call should be faster than 100ms")
	# 戻り値が等しい
	assert_eq(first, second)

	# 独立性の確認: 2回目の戻り値を書き換えても、3回目は影響を受けない
	assert_gt(second.size(), 0, "Generated levels should not be empty")
	assert_true(second[0].has("regions"), "First generated level should have regions")
	second[0]["regions"][0][0] = 99

	# 3回目
	var third = LevelPack.generated_levels()
	assert_ne(third[0]["regions"][0][0], 99, "Cache should be independent of modified copy")


## CHECK: 2
func test_level_dicts_cache_speed_and_size() -> void:
	# 1回目
	var t0 = Time.get_ticks_msec()
	var first = LevelPack.level_dicts()
	var t1 = Time.get_ticks_msec()
	var duration_first = t1 - t0

	# 2回目
	var t2 = Time.get_ticks_msec()
	var second = LevelPack.level_dicts()
	var t3 = Time.get_ticks_msec()
	var duration_second = t3 - t2

	# 2回目は100ms未満
	assert_true(duration_second < 100, "Second call should be faster than 100ms")
	# 戻り値が等しい
	assert_eq(first, second)
	# 個数が35個
	assert_eq(second.size(), 35)
