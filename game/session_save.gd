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
	
	return {
		"level_index": int(data["level_index"]),
		"score": int(data["score"]),
		"hints": int(data["hints"])
	}
