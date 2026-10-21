extends GutTest

## CHECK: 1
func test_best_from_clears() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	var clears = [
		{"level": 1, "seconds": 10.0, "moves": 5},
		{"level": 1.0, "seconds": 7.5, "moves": 4},
		{"level": 2, "seconds": 3.0, "moves": 2},
		{"level": 1, "seconds": 9.0, "moves": 6}
	]
	var result = Payload.best_from_clears(clears)
	assert_eq(result, {
		"1": {"last": 9.0, "best": 7.5, "count": 3, "moves": 6},
		"2": {"last": 3.0, "best": 3.0, "count": 1, "moves": 2}
	})
	assert_eq(Payload.best_from_clears([]), {})

## CHECK: 2
func test_server_is_newer() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	assert_true(Payload.server_is_newer(3, 4))
	assert_false(Payload.server_is_newer(4, 4))
	assert_false(Payload.server_is_newer(5, 4))
