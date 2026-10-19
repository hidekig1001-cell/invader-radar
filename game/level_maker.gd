extends RefCounted

const MAX_ATTEMPTS := 2000

static func make_level(width: int, height: int, seed: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	for attempt in range(MAX_ATTEMPTS):
		var level_dict = attempt_level(rng, width)
		if not level_dict.is_empty():
			if has_unique_solution(level_dict):
				return level_dict
	
	# Fallback: return the last generated one even if not unique (should not happen with enough attempts)
	# Note: rng state has advanced through MAX_ATTEMPTS calls. 
	# We try one more time to get a valid structure, though uniqueness might fail.
	var final_dict = attempt_level(rng, width)
	if not final_dict.is_empty():
		return final_dict
		
	# If everything fails (extremely unlikely), return an empty dict or handle error.
	# Based on original code, it returned the last built one. 
	# attempt_level returns {} if solution is empty. 
	# If we reach here, all attempts had empty solutions or non-unique solutions.
	# The original code fell back to building with the current seed.
	# Here, since we don't change seed, we just return the last attempt_level result if it exists,
	# otherwise an empty dict.
	return {}

static func attempt_level(rng: RandomNumberGenerator, width: int) -> Dictionary:
	var solution = pick_solution(rng, width)
	if solution.is_empty():
		return {}
		
	var region_rows = grow_regions(rng, width, solution)
	var level_dict = build_level_dict(width, solution, region_rows)
	level_dict["radar"] = pick_radar(rng, solution)
	
	if width >= 7:
		level_dict["asteroids"] = pick_asteroids(rng, solution, level_dict["radar"])
		
	return level_dict

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
			var chosen_index = rng.randi_range(0, valid_neighbors.size() - 1)
			var chosen = valid_neighbors[chosen_index]
			grid[chosen.y][chosen.x] = grid[cell.y][cell.x]
			queue.append(chosen)
			
			# If there are still unvisited neighbors left for this cell, re-queue it to process them later
			if valid_neighbors.size() > 1:
				queue.append(cell)
			
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

static func pick_radar(rng: RandomNumberGenerator, solution: Array) -> Array:
	var Rules = preload("res://core/rules.gd")
	var size = solution.size()
	var pieces = []
	for y in range(size):
		pieces.append(Vector2i(solution[y], y))
		
	var empty_cells = []
	for y in range(size):
		for x in range(size):
			if x != solution[y]:
				empty_cells.append([x, y])
				
	if empty_cells.is_empty():
		return []
		
	# Shuffle empty cells deterministically using rng
	for i in range(empty_cells.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = empty_cells[i]
		empty_cells[i] = empty_cells[j]
		empty_cells[j] = temp
		
	var count: int
	if size >= 8:
		count = rng.randi_range(3, 5)
	else:
		count = rng.randi_range(1, 2)
		
	if count > empty_cells.size():
		count = empty_cells.size()
		
	var result = []
	for i in range(count):
		var cell = empty_cells[i]
		var x = cell[0]
		var y = cell[1]
		var n = Rules.radar_count(pieces, x, y)
		result.append([x, y, n])
		
	return result

static func pick_asteroids(rng: RandomNumberGenerator, solution: Array, radar: Array) -> Array:
	var size = solution.size()
	var empty_cells = []
	
	for y in range(size):
		for x in range(size):
			# Check if cell is a solution piece
			if x == solution[y]:
				continue
			
			# Check if cell is a radar cell
			var is_radar = false
			for r in radar:
				if r[0] == x and r[1] == y:
					is_radar = true
					break
			if is_radar:
				continue
				
			empty_cells.append([x, y])
			
	if empty_cells.is_empty():
		return []
		
	# Shuffle empty cells deterministically using rng
	for i in range(empty_cells.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = empty_cells[i]
		empty_cells[i] = empty_cells[j]
		empty_cells[j] = temp
		
	var count = rng.randi_range(1, 2)
	if count > empty_cells.size():
		count = empty_cells.size()
		
	var result = []
	for i in range(count):
		result.append(empty_cells[i])
		
	return result
