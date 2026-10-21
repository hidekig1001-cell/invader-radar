# サーバー（Firebase）に進み具合を保存する口。この段では通信しない。
extends Node

const SessionSave = preload("res://game/session_save.gd")

var config_path: String = ""
var state_path: String = "user://cloud_state.json"
var local_store = null
var http = null


func is_configured() -> bool:
	var c = SessionSave.read_dict(config_path)
	return str(c.get("project_id", "")) != "" and str(c.get("web_api_key", "")) != ""


func ensure_http() -> bool:
	if not is_configured():
		return false
	if http == null:
		http = HTTPRequest.new()
		add_child(http)
	return true


func load_state() -> Dictionary:
	return SessionSave.read_dict(state_path)


func load_progress() -> Dictionary:
	if local_store == null:
		return {}
	return local_store.load_progress()


func save_progress(data: Dictionary) -> void:
	if local_store != null:
		local_store.save_progress(data)
	var state = load_state()
	state["rev"] = int(state.get("rev", 0)) + 1
	SessionSave.write_json(state_path, state)


func clear() -> void:
	if local_store != null:
		local_store.clear()
