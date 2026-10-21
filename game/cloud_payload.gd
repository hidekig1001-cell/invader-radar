extends RefCounted


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
