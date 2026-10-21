extends RefCounted

const SessionSave = preload("res://game/session_save.gd")
const PATH := "user://settings.json"


static func load_muted(path: String) -> bool:
	var data = SessionSave.read_dict(path)
	if data.has("muted"):
		return bool(data["muted"])
	return false


static func save_muted(path: String, muted: bool) -> void:
	var data = SessionSave.read_dict(path)
	data["muted"] = muted
	SessionSave.write_json(path, data)


static func apply(muted: bool) -> void:
	AudioServer.set_bus_mute(0, muted)
