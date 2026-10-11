# 画面の層（SPEC.md 3 節）: 触った位置と時刻の並び → tap・double_tap・swipe とマス。
# Node に触れない関数だけ（テストで確かめる）。
#   stroke = 指を置いてから離すまでの点の並び [{"pos": Vector2, "t": int（ms）}, ...]
#   geom   = 盤の位置 {"origin": Vector2, "cell": float（1 マスの辺）, "w": int, "h": int}
#   prev_tap = 直前の tap の記録 {"cell": Vector2i, "t": int}（なければ {}）
extends RefCounted

const DOUBLE_TAP_MS := 300  # 同じマスをこの時間以内にもう一度 → double_tap
const TAP_SLOP_RATIO := 0.2  # 置いた点からこの割合（1 マスに対して）以内しか動かなければ tap
const SAMPLE_RATIO := 0.25  # 点と点の間を、1 マスのこの割合ごとに調べて、飛ばしたマスを拾う
const NO_CELL := Vector2i(-1, -1)


# 位置のマス。盤の外なら NO_CELL。
static func cell_at(pos: Vector2, geom: Dictionary) -> Vector2i:
	var cs: float = geom["cell"]
	var local: Vector2 = pos - (geom["origin"] as Vector2)
	if cs <= 0.0 or local.x < 0.0 or local.y < 0.0:
		return NO_CELL
	var cx := int(floor(local.x / cs))
	var cy := int(floor(local.y / cs))
	if cx >= int(geom["w"]) or cy >= int(geom["h"]):
		return NO_CELL
	return Vector2i(cx, cy)


# 1 本のなぞりを読む。
# 戻り値: {"kind": "tap"|"double_tap"|"swipe"|"none", "cell": Vector2i, "cells": Array（swipe のマス）,
#         "tap_record": 次の呼び出しに渡す prev_tap}
static func classify(stroke: Array, prev_tap: Dictionary, geom: Dictionary) -> Dictionary:
	var none := {"kind": "none", "cell": NO_CELL, "cells": [], "tap_record": {}}
	if stroke.is_empty():
		return none
	var first: Vector2 = stroke[0]["pos"]
	var start_cell := cell_at(first, geom)
	if start_cell == NO_CELL:
		return none
	var slop: float = float(geom["cell"]) * TAP_SLOP_RATIO
	var max_dist := 0.0
	for p in stroke:
		max_dist = maxf(max_dist, first.distance_to(p["pos"]))
	if max_dist <= slop:
		var t: int = stroke[stroke.size() - 1]["t"]
		if not prev_tap.is_empty() and prev_tap["cell"] == start_cell and t - int(prev_tap["t"]) <= DOUBLE_TAP_MS:
			return {"kind": "double_tap", "cell": start_cell, "cells": [], "tap_record": {}}
		return {"kind": "tap", "cell": start_cell, "cells": [],
			"tap_record": {"cell": start_cell, "t": t}}
	return {"kind": "swipe", "cell": start_cell, "cells": cells_along(stroke, geom), "tap_record": {}}


# なぞった順の、盤の中のマス（重ならない）。点と点の間のマスも拾う。
static func cells_along(stroke: Array, geom: Dictionary) -> Array:
	var cells: Array = []
	var step: float = maxf(float(geom["cell"]) * SAMPLE_RATIO, 1.0)
	for i in range(stroke.size()):
		var a: Vector2 = stroke[i]["pos"]
		_add_cell(cells, cell_at(a, geom))
		if i + 1 < stroke.size():
			var b: Vector2 = stroke[i + 1]["pos"]
			var n := int(ceil(a.distance_to(b) / step))
			for k in range(1, n):
				_add_cell(cells, cell_at(a.lerp(b, float(k) / float(n)), geom))
	return cells


# なぞりの並びを順に読む（none は除く）。結果: [{"kind", "cell", "cells"}, ...]
static func map_all(strokes: Array, geom: Dictionary) -> Array:
	var out: Array = []
	var prev: Dictionary = {}
	for s in strokes:
		var r := classify(s, prev, geom)
		prev = r["tap_record"]
		if r["kind"] != "none":
			out.append({"kind": r["kind"], "cell": r["cell"], "cells": r["cells"]})
	return out


static func _add_cell(cells: Array, c: Vector2i) -> void:
	if c != NO_CELL and not cells.has(c):
		cells.append(c)
