extends RefCounted

const SessionSave = preload("res://game/session_save.gd")

var path: String = ""


func load_progress() -> Dictionary:
	if path == "":
		return {}
	return SessionSave.read_json(path)


func save_progress(data: Dictionary) -> void:
	if path != "":
		SessionSave.write_json(path, data)


func clear() -> void:
	if path != "":
		SessionSave.write_text(path, "")
