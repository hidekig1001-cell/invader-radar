extends GutTest

const Payload = preload("res://game/cloud_payload.gd")


## CHECK: 1
func test_merge_best_merges_data_and_preserves_input() -> void:
	var cloud = {
		"1": {"last": 9.0, "best": 7.5, "count": 3, "moves": 6},
		"2": {"last": 3.0, "best": 3.0, "count": 1, "moves": 2}
	}
	var local = {
		"1": {"last": 8.0, "best": 8.0, "count": 1, "moves": 5},
		"3": {"last": 4.0, "best": 4.0, "count": 1, "moves": 3}
	}
	var expected = {
		"1": {"last": 8.0, "best": 7.5, "count": 4, "moves": 5},
		"2": {"last": 3.0, "best": 3.0, "count": 1, "moves": 2},
		"3": {"last": 4.0, "best": 4.0, "count": 1, "moves": 3}
	}
	var result = Payload.merge_best(cloud, local)
	assert_eq(result, expected)
	assert_eq(cloud["1"]["count"], 3)


## CHECK: 2
func test_merge_best_empty_and_only_cloud() -> void:
	assert_eq(Payload.merge_best({}, {}), {})
	var only_cloud = {"5": {"last": 2.0, "best": 2.0, "count": 2, "moves": 9}}
	var result = Payload.merge_best(only_cloud, {})
	assert_eq(result, only_cloud)
