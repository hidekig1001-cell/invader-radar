extends RefCounted

const MAX_ATTEMPTS := 2000

static func make_level(width: int, height: int, seed: int) -> Dictionary:
	var current_seed = seed
	for attempt in range(MAX_ATTEMPTS):
		var rng = RandomNumberGenerator.new()
		rng.seed = current_seed
		
		var solution = pick_solution(rng, width)
		if solution.is_empty():
			current_seed += 1
			continue
			
		var region_rows = grow_regions(rng, width, solution)
		var level_dict = build_level_dict(width, solution, region_rows)
		
		if has_unique_solution(level_dict):
			return level_dict
			
		current_seed += 1
		
	# Fallback: return the last generated one even if not unique (should not happen with enough attempts)
	var rng = RandomNumberGenerator.new()
	rng.seed = current_seed
	var solution = pick_solution(rng, width)
	var region_rows = grow_regions(rng, width, solution)
	return build_level_dict(width, solution, region_rows)

static func pick_solution(rng: RandomNumberGenerator, size: int) -> Array:
	var cols := []
	for i in range(size):
		cols.append(i)
		
	for attempt in range(1000):
		# Manual Fisher-Yates shuffle using rng.randi_range
		for i in range(cols.size() - 1, 0, -1):
			var j = rng.randi_range(0, i)
			var temp = cols[i]
			cols[i] = cols[j]
			cols[j] = temp
			
		var valid = true
		for i in range(size - 1):
			if abs(cols[i] - cols[i+1]) == 1:
				valid = false
				break
		if valid:
			return cols.duplicate()
			
	return []

static func grow_regions(rng: RandomNumberGenerator, size: int, solution: Array) -> Array:
	var grid := []
	for y in range(size):
		var row := []
		for x in range(size):
			row.append(-1)
		grid.append(row)
		
	var queue := []
	for i in range(size):
		var x = solution[i]
		var y = i
		grid[y][x] = i
		queue.append(Vector2i(x, y))
		
	while not queue.is_empty():
		var cell = queue.pop_front()
		var neighbors = [
			Vector2i(cell.x + 1, cell.y),
			Vector2i(cell.x - 1, cell.y),
			Vector2i(cell.x, cell.y + 1),
			Vector2i(cell.x, cell.y - 1)
		]
		
		var valid_neighbors := []
		for n in neighbors:
			if n.x >= 0 and n.x < size and n.y >= 0 and n.y < size:
				if grid[n.y][n.x] == -1:
					valid_neighbors.append(n)
					
		if not valid_neighbors.is_empty():
			var chosen = valid_neighbors[rng.randi_range(0, valid_neighbors.size() - 1)]
			grid[chosen.y][chosen.x] = grid[cell.y][cell.x]
			queue.append(chosen)
			
	return grid

static func build_level_dict(size: int, solution: Array, region_rows: Array) -> Dictionary:
	return {
		"id": 0,
		"width": size,
		"height": size,
		"target": size,
		"regions": region_rows
	}

static func has_unique_solution(level_dict: Dictionary) -> bool:
	var Level = preload("res://game/level.gd")
	var Solver = preload("res://core/solver.gd")
	
	var level = Level.new()
	if not level.parse(level_dict):
		return false
		
	return Solver.count_solutions(level, 2) == 1
