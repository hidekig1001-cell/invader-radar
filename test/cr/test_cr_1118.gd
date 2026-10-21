extends GutTest

const Save = preload("res://game/session_save.gd")
const StoreScript = preload("res://scenes/cloud_store.gd")
const Payload = preload("res://game/cloud_payload.gd")


func _make_cs() -> Node:
	var cs = autofree(StoreScript.new())
	cs.config_path = "user://test_cr_1118_config.json"
	cs.state_path = "user://test_cr_1118_state.json"
	Save.write_json(cs.config_path, {"project_id": "p1", "web_api_key": "K"})
	return cs


## CHECK: 1
func test_cr1118_1_best_merged_with_cloud_best() -> void:
	var cs = _make_cs()
	Save.write_json(cs.state_path, {
		"rev": 4,
		"uid": "u9",
		"id_token": "t9",
		"cloud_best": {"1": {"last": 30.5, "best": 20.5, "count": 2, "moves": 9}}
	})
	cs.queued = {
		"level_index": 1,
		"score": 5,
		"hints": 3,
		"clears": [{"level": 1, "seconds": 25.5, "moves": 7}]
	}
	var req = cs.push_fields()
	var body = JSON.parse_string(req["body"])
	var best = Payload.from_value(body["writes"][0]["update"]["fields"]["best"])
	assert_eq(best["1"]["count"], 3)
	assert_eq(best["1"]["best"], 20.5)
	assert_eq(best["1"]["last"], 25.5)
	assert_eq(best["1"]["moves"], 7)


## CHECK: 1
func test_cr1118_2_best_without_cloud_best() -> void:
	var cs = _make_cs()
	Save.write_json(cs.state_path, {
		"rev": 4,
		"uid": "u9",
		"id_token": "t9"
	})
	cs.queued = {
		"level_index": 1,
		"score": 5,
		"hints": 3,
		"clears": [{"level": 1, "seconds": 25.5, "moves": 7}]
	}
	var req2 = cs.push_fields()
	var body2 = JSON.parse_string(req2["body"])
	var best2 = Payload.from_value(body2["writes"][0]["update"]["fields"]["best"])
	assert_eq(best2["1"]["count"], 1)
