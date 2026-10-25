# 規則の層（SPEC.md 2 節）: ゲームの決まりの入口。
# Meowdoku の決まり: 駒は、同じ行・同じ列・同じ区域に 2 つ置けない。
# また、縦・横・斜めに隣り合う 2 マスにも置けない。
# さらに、小惑星のマスには駒を置けない。
extends RefCounted


static func conflicts(board_state, level) -> Array:
	if board_state == null or level == null:
		return []
	
	var pieces = board_state.pieces()
	var conflict_set = {}
	var n = pieces.size()
	
	# 小惑星のマスにある駒を conflict_set に追加
	for piece in pieces:
		for asteroid in level.asteroids:
			if piece == asteroid:
				conflict_set[piece] = true
				break
	
	# レーダー（数字）のマスにある駒を conflict_set に追加
	for piece in pieces:
		for r in level.radar:
			var rx = r[0]
			var ry = r[1]
			if piece.x == rx and piece.y == ry:
				conflict_set[piece] = true
				break
	
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
	
	# レーダーの衝突を追加
	var radar_conf = radar_conflicts(board_state, level)
	for piece in radar_conf:
		conflict_set[piece] = true
	
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
	if not conflicts(board_state, level).is_empty():
		return false
	if not radar_satisfied(board_state.pieces(), level):
		return false
	return true


static func radar_count(pieces, x: int, y: int) -> int:
	var count = 0
	for piece in pieces:
		var dx = abs(piece.x - x)
		var dy = abs(piece.y - y)
		if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0):
			count += 1
	return count


static func radar_conflicts(board_state, level) -> Array:
	if board_state == null or level == null:
		return []
	
	var result = []
	var pieces = board_state.pieces()
	
	for r in level.radar:
		var rx = r[0]
		var ry = r[1]
		var n = r[2]
		
		var count = radar_count(pieces, rx, ry)
		if count > n:
			for piece in pieces:
				var dx = abs(piece.x - rx)
				var dy = abs(piece.y - ry)
				if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0):
					result.append(piece)
	
	return result


static func radar_satisfied(pieces, level) -> bool:
	if level == null:
		return true
	
	for r in level.radar:
		var rx = r[0]
		var ry = r[1]
		var n = r[2]
		
		var count = radar_count(pieces, rx, ry)
		if count != n:
			return false
	
	return true


static func dead_marks(board_state, level) -> Array:
	if board_state == null or level == null:
		return []
	
	var width = level.width
	var height = level.height
	var result_set = {}
	
	# Helper to check if a cell is an asteroid
	var is_asteroid = func(x, y):
		for a in level.asteroids:
			if a.x == x and a.y == y:
				return true
		return false

	# Helper to check if a cell is a radar number cell
	var is_radar_cell = func(x, y):
		for r in level.radar:
			if r[0] == x and r[1] == y:
				return true
		return false

	# Check Rows
	for y in range(height):
		var has_alien = false
		var all_marks = true
		var marks_in_row = []
		
		for x in range(width):
			var state = board_state.state_at(x, y)
			if state == 2: # Alien/Piece
				has_alien = true
				break
			elif is_asteroid.call(x, y) or is_radar_cell.call(x, y):
				continue
			elif state == 1: # Mark
				marks_in_row.append(Vector2i(x, y))
			else:
				all_marks = false
				break
		
		if not has_alien and all_marks and not marks_in_row.is_empty():
			for m in marks_in_row:
				result_set[m] = true

	# Check Columns
	for x in range(width):
		var has_alien = false
		var all_marks = true
		var marks_in_col = []
		
		for y in range(height):
			var state = board_state.state_at(x, y)
			if state == 2: # Alien/Piece
				has_alien = true
				break
			elif is_asteroid.call(x, y) or is_radar_cell.call(x, y):
				continue
			elif state == 1: # Mark
				marks_in_col.append(Vector2i(x, y))
			else:
				all_marks = false
				break
		
		if not has_alien and all_marks and not marks_in_col.is_empty():
			for m in marks_in_col:
				result_set[m] = true

	# Check Regions
	var region_count = level.region_count()
	for r_id in range(region_count):
		var has_alien = false
		var all_marks = true
		var marks_in_region = []
		
		for y in range(height):
			for x in range(width):
				if level.region_at(x, y) != r_id:
					continue
				
				var state = board_state.state_at(x, y)
				if state == 2: # Alien/Piece
					has_alien = true
					break
				elif is_asteroid.call(x, y) or is_radar_cell.call(x, y):
					continue
				elif state == 1: # Mark
					marks_in_region.append(Vector2i(x, y))
				else:
					all_marks = false
					break
			
			if has_alien or not all_marks:
				break
		
		if not has_alien and all_marks and not marks_in_region.is_empty():
			for m in marks_in_region:
				result_set[m] = true

	var result = []
	for key in result_set.keys():
		result.append(key)
	
	result.sort_custom(func(a, b):
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)
	
	return result
