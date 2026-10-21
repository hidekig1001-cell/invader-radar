# サーバー（Firebase）に進み具合を保存する口。この段では通信しない。
extends Node

const SessionSave = preload("res://game/session_save.gd")
const Payload = preload("res://game/cloud_payload.gd")

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


func on_signup_done(code: int, text: String) -> bool:
	if code != 200:
		return false
	var json = JSON.new()
	if json.parse(text) != OK:
		return false
	var data = json.data
	if not (data is Dictionary):
		return false
	if not data.has("localId") or not data.has("idToken") or not data.has("refreshToken"):
		return false
	var state = load_state()
	state["uid"] = str(data["localId"])
	state["id_token"] = str(data["idToken"])
	state["refresh_token"] = str(data["refreshToken"])
	SessionSave.write_json(state_path, state)
	return true


func on_get_done(code: int, text: String) -> Dictionary:
	if code != 200:
		return {}
	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	var data = json.data
	if not (data is Dictionary):
		return {}
	if not (data.get("fields") is Dictionary):
		return {}
	return Payload.read_fields(data["fields"])


func signup_request() -> Dictionary:
	var config = SessionSave.read_dict(config_path)
	var web_api_key = str(config.get("web_api_key", ""))
	var url = Payload.signup_url(web_api_key)
	var headers = ["Content-Type: application/json"]
	var method = HTTPClient.METHOD_POST
	var body = JSON.stringify({"returnSecureToken": true})
	return {
		"url": url,
		"headers": headers,
		"method": method,
		"body": body
	}


func get_request() -> Dictionary:
	var config = SessionSave.read_dict(config_path)
	var project_id = str(config.get("project_id", ""))
	var state = load_state()
	var uid = str(state.get("uid", ""))
	var id_token = str(state.get("id_token", ""))
	var url = Payload.doc_url(project_id, uid)
	var headers = ["Authorization: Bearer " + id_token]
	var method = HTTPClient.METHOD_GET
	var body = ""
	return {
		"url": url,
		"headers": headers,
		"method": method,
		"body": body
	}


func commit_request(fields: Dictionary) -> Dictionary:
	var config = SessionSave.read_dict(config_path)
	var project_id = str(config.get("project_id", ""))
	var state = load_state()
	var uid = str(state.get("uid", ""))
	var id_token = str(state.get("id_token", ""))
	var url = Payload.commit_url(project_id)
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + id_token]
	var method = HTTPClient.METHOD_POST
	var body = JSON.stringify(Payload.commit_body(project_id, uid, fields))
	return {
		"url": url,
		"headers": headers,
		"method": method,
		"body": body
	}


func send(req: Dictionary) -> int:
	if not ensure_http():
		return ERR_UNCONFIGURED
	return http.request(req["url"], req["headers"], req["method"], req["body"])
