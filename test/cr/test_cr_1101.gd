extends GutTest

## CHECK: 1
func test_to_value_primitives() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	assert_eq(Payload.to_value(3), {"integerValue": "3"})
	assert_eq(Payload.to_value(1.5), {"doubleValue": 1.5})
	assert_eq(Payload.to_value("ab"), {"stringValue": "ab"})
	assert_eq(Payload.to_value(true), {"booleanValue": true})


## CHECK: 1
func test_to_value_collections() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	assert_eq(Payload.to_value(["a", 2]), {"arrayValue": {"values": [{"stringValue": "a"}, {"integerValue": "2"}]}})
	assert_eq(Payload.to_value({"k": 1}), {"mapValue": {"fields": {"k": {"integerValue": "1"}}}})


## CHECK: 2
func test_from_value_primitives() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	var v_int = Payload.from_value({"integerValue": "7"})
	assert_eq(v_int, 7)
	assert_eq(typeof(v_int), TYPE_INT)
	assert_eq(Payload.from_value({"arrayValue": {}}), [])
	assert_eq(Payload.from_value({"mapValue": {}}), {})


## CHECK: 2
func test_roundtrip() -> void:
	var Payload = load("res://game/cloud_payload.gd")
	var d = {"level_index": 2, "rows": [".x", "o."], "elapsed": 2.5, "level": {"id": 11}}
	assert_eq(Payload.from_value(Payload.to_value(d)), d)
