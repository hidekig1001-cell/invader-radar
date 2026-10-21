extends RefCounted


static func write_text(path: String, text: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()


static func write_json(path: String, data: Dictionary) -> void:
	write_text(path, JSON.stringify(data))


static func read_json(path: String) -> Dictionary:
	var text = FileAccess.get_file_as_string(path)
	if text == "":
		return {}
	
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		return {}
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	
	if not data.has("level_index") or not data.has("score") or not data.has("hints"):
		return {}
	
	var out = {
		"level_index": int(data["level_index"]),
		"score": int(data["score"]),
		"hints": int(data["hints"])
	}
	
	if data.has("max_cleared"):
		out["max_cleared"] = int(data["max_cleared"])
	
	if data.has("clears") and typeof(data["clears"]) == TYPE_ARRAY:
		var raw_clears = data["clears"]
		var clean_clears = []
		for r in raw_clears:
			if typeof(r) == TYPE_DICTIONARY:
				clean_clears.append({
					"level": int(r.get("level", 0)),
					"seconds": float(r.get("seconds", 0.0)),
					"moves": int(r.get("moves", 0))
				})
		out["clears"] = clean_clears
	
	if data.has("moves"):
		out["moves"] = int(data["moves"])
	
	if data.has("elapsed"):
		out["elapsed"] = float(data["elapsed"])
	
	if data.has("level") and typeof(data["level"]) == TYPE_DICTIONARY:
		out["level"] = data["level"]
	
	if data.has("rows") and typeof(data["rows"]) == TYPE_ARRAY:
		var clean_rows = []
		for r in data["rows"]:
			if typeof(r) == TYPE_STRING:
				clean_rows.append(r)
		out["rows"] = clean_rows
	
	return out


static func read_dict(path: String) -> Dictionary:
	var text = FileAccess.get_file_as_string(path)
	if text == "":
		return {}
	
	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	
	if typeof(json.data) != TYPE_DICTIONARY:
		return {}
	
	return json.data
