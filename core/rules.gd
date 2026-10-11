# 規則の層（SPEC.md 2 節）: ゲームの決まりの入口。
# Meowdoku の決まり: 駒は、同じ行・同じ列・同じ区域に 2 つ置けない。
# また、縦・横・斜めに隣り合う 2 マスにも置けない。
extends RefCounted


static func conflicts(board_state, level) -> Array:
	if board_state == null or level == null:
		return []
	
	var pieces = board_state.pieces()
	var conflict_set = {}
	var n = pieces.size()
	
	for i in range(n):
		for j in range(i + 1, n):
			var a = pieces[i]
			var b = pieces[j]
			
			var is_conflict = false
			
			# 同じ行 (y)
			if a.y == b.y:
				is_conflict = true
			# 同じ列 (x)
			elif a.x == b.x:
				is_conflict = true
			# 同じ区域
			elif level.region_at(a.x, a.y) == level.region_at(b.x, b.y):
				is_conflict = true
			# 隣接 (縦・横・斜め): x の差も y の差も 1 以下
			else:
				var dx = abs(a.x - b.x)
				var dy = abs(a.y - b.y)
				if dx <= 1 and dy <= 1:
					is_conflict = true
			
			if is_conflict:
				conflict_set[a] = true
				conflict_set[b] = true
	
	var result = []
	for key in conflict_set.keys():
		result.append(key)
	
	# y の小さい順、y が同じなら x の小さい順にソート
	result.sort_custom(func(a, b):
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)
	
	return result


static func is_solved(board_state, level) -> bool:
	if board_state == null or level == null:
		return false
	if board_state.pieces().size() != level.target:
		return false
	return conflicts(board_state, level).is_empty()
