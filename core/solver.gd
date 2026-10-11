extends RefCounted

static func solutions(level, limit: int = 0) -> Array:
	if level == null:
		return []
	if level.width != level.height:
		return []
	if level.region_count() != level.width:
		return []
	if level.target != level.width:
		return []
	
	var n = level.width
	var results = []
	var current_solution = []
	var used_cols = {}
	var used_regions = {}
	var prev_x = -10
	
	_backtrack(level, n, 0, current_solution, used_cols, used_regions, prev_x, results, limit)
	return results

static func _backtrack(level, n: int, y: int, current_solution: Array, used_cols: Dictionary, used_regions: Dictionary, prev_x: int, results: Array, limit: int) -> void:
	if limit > 0 and results.size() >= limit:
		return
	
	if y == n:
		results.append(current_solution.duplicate())
		return
	
	for x in range(n):
		if used_cols.has(x):
			continue
		
		var region = level.region_at(x, y)
		if used_regions.has(region):
			continue
		
		if abs(x - prev_x) <= 1:
			continue
		
		if _is_asteroid(level, x, y):
			continue
		
		current_solution.append(Vector2i(x, y))
		used_cols[x] = true
		used_regions[region] = true
		
		_backtrack(level, n, y + 1, current_solution, used_cols, used_regions, x, results, limit)
		
		current_solution.pop_back()
		used_cols.erase(x)
		used_regions.erase(region)

static func _is_asteroid(level, x: int, y: int) -> bool:
	for a in level.asteroids:
		if a.x == x and a.y == y:
			return true
	return false

static func count_solutions(level, limit: int = 0) -> int:
	return solutions(level, limit).size()
