extends GutTest

const Save = preload("res://game/session_save.gd")


## CHECK: 1
func test_cr1105_read_dict_basic_and_read_json_unchanged() -> void:
	var path = "user://test_cr_1105.json"
	
	# Empty file case
	Save.write_text(path, "")
	assert_eq(Save.read_dict(path), {})
	
	# Valid JSON with nested structure
	Save.write_json(path, {"rev": 4, "uid": "abc", "cloud_best": {"1": {"best": 7.5}}})
	var d = Save.read_dict(path)
	assert_eq(d["uid"], "abc")
	assert_eq(int(d["rev"]), 4)
	assert_eq(d["cloud_best"]["1"]["best"], 7.5)
	
	# read_json should still return {} because required fields are missing
	assert_eq(Save.read_json(path), {})


## CHECK: 2
func test_cr1105_read_dict_invalid_inputs() -> void:
	var path = "user://test_cr_1105.json"
	
	# Invalid JSON string
	Save.write_text(path, "not json")
	assert_eq(Save.read_dict(path), {})
	
	# Valid JSON but not a dictionary (array)
	Save.write_text(path, "[1, 2]")
	assert_eq(Save.read_dict(path), {})
	
	# Missing file
	assert_eq(Save.read_dict("user://test_cr_1105_missing.json"), {})
