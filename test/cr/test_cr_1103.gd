extends GutTest

const Payload = preload("res://game/cloud_payload.gd")


## CHECK: 1
func test_build_fields_structure() -> void:
	var save = {
		"level_index": 2.0,
		"score": 300.0,
		"hints": 1.0,
		"max_cleared": 3.0,
		"moves": 4.0,
		"elapsed": 12.5,
		"rows": [".x", "o."],
		"level": {"id": 3},
		"clears": [{"level": 3, "seconds": 12.5, "moves": 4}]
	}
	var f = Payload.build_fields(save, 5, "1.02")

	assert_eq(f["rev"], {"integerValue": "5"})
	assert_eq(f["level_index"], {"integerValue": "2"})
	assert_eq(f["max_cleared"], {"integerValue": "3"})
	assert_eq(f["elapsed"], {"doubleValue": 12.5})
	assert_eq(f["app_version"], {"stringValue": "1.02"})
	assert_false(f.has("clears"))

	var expected_best = Payload.to_value({"3": {"last": 12.5, "best": 12.5, "count": 1, "moves": 4}})
	assert_eq(f["best"], expected_best)

	var keys = f.keys()
	keys.sort()
	assert_eq(keys, ["app_version", "best", "elapsed", "hints", "level", "level_index", "max_cleared", "moves", "rev", "rows", "score"])


## CHECK: 2
func test_read_fields_roundtrip() -> void:
	var save = {
		"level_index": 2.0,
		"score": 300.0,
		"hints": 1.0,
		"max_cleared": 3.0,
		"moves": 4.0,
		"elapsed": 12.5,
		"rows": [".x", "o."],
		"level": {"id": 3},
		"clears": [{"level": 3, "seconds": 12.5, "moves": 4}]
	}
	var fields = Payload.build_fields(save, 5, "1.02")
	var r = Payload.read_fields(fields)

	assert_eq(r["rev"], 5)
	assert_eq(r["score"], 300)
	assert_eq(typeof(r["score"]), TYPE_INT)
	assert_eq(r["rows"], [".x", "o."])

	assert_eq(Payload.read_fields({}), {})
