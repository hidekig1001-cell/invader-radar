extends RefCounted

const INT_KEYS := ["level_index", "score", "hints", "max_cleared", "moves"]


static func to_value(v) -> Dictionary:
	match typeof(v):
		TYPE_BOOL:
			return {"booleanValue": v}
		TYPE_INT:
			return {"integerValue": str(v)}
		TYPE_FLOAT:
			return {"doubleValue": v}
		TYPE_STRING:
			return {"stringValue": v}
		TYPE_ARRAY:
			var values = []
			for item in v:
				values.append(to_value(item))
			return {"arrayValue": {"values": values}}
		TYPE_DICTIONARY:
			var fields = {}
			for key in v.keys():
				fields[str(key)] = to_value(v[key])
			return {"mapValue": {"fields": fields}}
		_:
			return {"nullValue": null}


static func from_value(f: Dictionary):
	if f.has("booleanValue"):
		return bool(f["booleanValue"])
	elif f.has("integerValue"):
		return str(f["integerValue"]).to_int()
	elif f.has("doubleValue"):
		return float(f["doubleValue"])
	elif f.has("stringValue"):
		return str(f["stringValue"])
	elif f.has("arrayValue"):
		var arr_data = f["arrayValue"]
		if arr_data is Dictionary and arr_data.has("values"):
			var values = arr_data["values"]
			var result = []
			for item in values:
				result.append(from_value(item))
			return result
		else:
			return []
	elif f.has("mapValue"):
		var map_data = f["mapValue"]
		if map_data is Dictionary and map_data.has("fields"):
			var fields = map_data["fields"]
			var result = {}
			for key in fields.keys():
				result[key] = from_value(fields[key])
			return result
		else:
			return {}
	else:
		return null


static func best_from_clears(clears: Array) -> Dictionary:
	var out: Dictionary = {}
	for c in clears:
		if typeof(c) != TYPE_DICTIONARY:
			continue
		var key := str(int(c.get("level", 0)))
		var sec := float(c.get("seconds", 0.0))
		var mv := int(c.get("moves", 0))
		if not out.has(key):
			out[key] = {"last": sec, "best": sec, "count": 1, "moves": mv}
		else:
			var e: Dictionary = out[key]
			e["last"] = sec
			e["best"] = minf(float(e["best"]), sec)
			e["count"] = int(e["count"]) + 1
			e["moves"] = mv
	return out


static func server_is_newer(local_rev: int, server_rev: int) -> bool:
	return server_rev > local_rev


static func merge_best(cloud_best: Dictionary, local_best: Dictionary) -> Dictionary:
	var out: Dictionary = cloud_best.duplicate(true)
	for k in local_best.keys():
		var l: Dictionary = local_best[k]
		if not out.has(k):
			out[k] = l.duplicate(true)
		else:
			var e: Dictionary = out[k]
			e["best"] = minf(float(e["best"]), float(l["best"]))
			e["count"] = int(e["count"]) + int(l["count"])
			e["last"] = float(l["last"])
			e["moves"] = int(l["moves"])
	return out


static func build_fields(save: Dictionary, rev: int, app_version: String) -> Dictionary:
	var doc: Dictionary = {"rev": rev}
	for k in INT_KEYS:
		if save.has(k):
			doc[k] = int(save[k])
	if save.has("elapsed"):
		doc["elapsed"] = float(save["elapsed"])
	if save.has("level"):
		doc["level"] = save["level"]
	if save.has("rows"):
		doc["rows"] = save["rows"]
	var clears = save.get("clears", [])
	doc["best"] = best_from_clears(clears if typeof(clears) == TYPE_ARRAY else [])
	doc["app_version"] = app_version
	var fields: Dictionary = {}
	for k in doc.keys():
		fields[k] = to_value(doc[k])
	return fields


static func read_fields(fields: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in fields.keys():
		if typeof(fields[k]) == TYPE_DICTIONARY:
			out[k] = from_value(fields[k])
	return out


static func signup_url(api_key: String) -> String:
	return "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + api_key


static func refresh_url(api_key: String) -> String:
	return "https://securetoken.googleapis.com/v1/token?key=" + api_key


static func commit_url(project_id: String) -> String:
	return "https://firestore.googleapis.com/v1/projects/" + project_id + "/databases/(default)/documents:commit"


static func doc_name(project_id: String, uid: String) -> String:
	return "projects/" + project_id + "/databases/(default)/documents/players/" + uid


static func doc_url(project_id: String, uid: String) -> String:
	return "https://firestore.googleapis.com/v1/" + doc_name(project_id, uid)


static func commit_body(project_id: String, uid: String, fields: Dictionary) -> Dictionary:
	var write: Dictionary = {
		"update": {
			"name": doc_name(project_id, uid),
			"fields": fields
		},
		"updateTransforms": [
			{
				"fieldPath": "updated_at",
				"setToServerValue": "REQUEST_TIME"
			}
		]
	}
	return {"writes": [write]}
