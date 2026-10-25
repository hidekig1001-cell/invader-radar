extends RefCounted

const Solver = preload("res://core/solver.gd")

static func analyze(level) -> Dictionary:
	var stuck := 0
	var key_move := false
	var max_cascade := 0
	var run := -1
	
	# Initialize candidates
	var cand := {}
	for y in range(level.height):
		for x in range(level.width):
			var is_asteroid = false
			for a in level.asteroids:
				if a.x == x and a.y == y:
					is_asteroid = true
					break
			if is_asteroid:
				continue
			
			var is_radar = false
			for r in level.radar:
				if r[0] == x and r[1] == y:
					is_radar = true
					break
			if is_radar:
				continue
				
			cand[Vector2i(x, y)] = true
			
	var pieces := []
	
	while pieces.size() < level.target:
		# (1) Forced cell
		var p = forced_cell(level, cand, pieces)
		if p != null:
			place(level, cand, pieces, p)
			if run >= 0:
				run += 1
			continue
			
		# (2) Eliminate
		if eliminate(level, cand, pieces):
			continue
			
		# (3) Stuck
		stuck += 1
		
		# Close current run if active
		if run >= 0:
			max_cascade = max(max_cascade, run)
			if run >= int(level.width / 2):
				key_move = true
				
		# Get solution and place first piece in topmost empty row
		var solutions = Solver.solutions(level, 1)
		if solutions.is_empty():
			break # Should not happen for valid levels
			
		var sol_pieces = solutions[0]
		var target_piece = null
		var min_y = level.height + 1
		
		for sp in sol_pieces:
			if not pieces.has(sp):
				if sp.y < min_y:
					min_y = sp.y
					target_piece = sp
					
		if target_piece == null:
			break # All solution pieces already placed?
			
		place(level, cand, pieces, target_piece)
		run = 0
		
	# Close final run if active
	if run >= 0:
		max_cascade = max(max_cascade, run)
		if run >= int(level.width / 2):
			key_move = true
			
	return {
		"stuck": stuck,
		"key_move": key_move,
		"max_cascade": max_cascade
	}

static func forced_cell(level, cand: Dictionary, pieces: Array):
	var w = level.width
	var h = level.height
	
	# Helper to check if a cell is in a specific row/col/region and has no piece
	# We need to find candidates that are the ONLY candidate in their row, col, or region (that doesn't have a piece)
	
	# 1. Check Rows
	for y in range(h):
		var has_piece = false
		for p in pieces:
			if p.y == y:
				has_piece = true
				break
		if has_piece:
			continue
			
		var row_cands = []
		for x in range(w):
			var pos = Vector2i(x, y)
			if cand.has(pos):
				row_cands.append(pos)
				
		if row_cands.size() == 1:
			return row_cands[0]
			
	# 2. Check Columns
	for x in range(w):
		var has_piece = false
		for p in pieces:
			if p.x == x:
				has_piece = true
				break
		if has_piece:
			continue
			
		var col_cands = []
		for y in range(h):
			var pos = Vector2i(x, y)
			if cand.has(pos):
				col_cands.append(pos)
				
		if col_cands.size() == 1:
			return col_cands[0]
			
	# 3. Check Regions
	var region_count = level.region_count()
	for r in range(region_count):
		var has_piece = false
		for p in pieces:
			if level.region_at(p.x, p.y) == r:
				has_piece = true
				break
		if has_piece:
			continue
			
		var reg_cands = []
		for y in range(h):
			for x in range(w):
				if level.region_at(x, y) == r:
					var pos = Vector2i(x, y)
					if cand.has(pos):
						reg_cands.append(pos)
						
		if reg_cands.size() == 1:
			return reg_cands[0]
			
	# 4. Check Radar constraints
	for r in level.radar:
		var rx = r[0]
		var ry = r[1]
		var rn = r[2]
		
		var pieces_around = 0
		var cands_around = []
		
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var nx = rx + dx
				var ny = ry + dy
				if nx < 0 or nx >= w or ny < 0 or ny >= h:
					continue
				var pos = Vector2i(nx, ny)
				if pieces.has(pos):
					pieces_around += 1
				elif cand.has(pos):
					cands_around.append(pos)
					
		if pieces_around + cands_around.size() == rn and cands_around.size() > 0:
			return cands_around[0]
			
	return null

static func eliminate(level, cand: Dictionary, pieces: Array) -> bool:
	var w = level.width
	var h = level.height
	var changed = false
	
	# (a) Radar constraint elimination
	for r in level.radar:
		var rx = r[0]
		var ry = r[1]
		var rn = r[2]
		
		var pieces_around = 0
		var cands_around = []
		
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var nx = rx + dx
				var ny = ry + dy
				if nx < 0 or nx >= w or ny < 0 or ny >= h:
					continue
				var pos = Vector2i(nx, ny)
				if pieces.has(pos):
					pieces_around += 1
				elif cand.has(pos):
					cands_around.append(pos)
					
		if pieces_around == rn:
			for pos in cands_around:
				if cand.has(pos):
					cand.erase(pos)
					changed = true
					
	# (b) Region-Row/Col interaction
	# "If all candidates in a region (without pieces) are in one row, eliminate candidates in that row outside the region"
	var region_count = level.region_count()
	for r in range(region_count):
		var has_piece = false
		for p in pieces:
			if level.region_at(p.x, p.y) == r:
				has_piece = true
				break
		if has_piece:
			continue
			
		var reg_cands = []
		for y in range(h):
			for x in range(w):
				if level.region_at(x, y) == r:
					var pos = Vector2i(x, y)
					if cand.has(pos):
						reg_cands.append(pos)
						
		if reg_cands.is_empty():
			continue
			
		# Check if all candidates are in the same row
		var first_y = reg_cands[0].y
		var all_same_row = true
		for c in reg_cands:
			if c.y != first_y:
				all_same_row = false
				break
				
		if all_same_row:
			# Eliminate candidates in this row that are NOT in region r
			for x in range(w):
				var pos = Vector2i(x, first_y)
				if cand.has(pos) and level.region_at(x, first_y) != r:
					cand.erase(pos)
					changed = true
					
		# Check if all candidates are in the same column
		var first_x = reg_cands[0].x
		var all_same_col = true
		for c in reg_cands:
			if c.x != first_x:
				all_same_col = false
				break
				
		if all_same_col:
			# Eliminate candidates in this column that are NOT in region r
			for y in range(h):
				var pos = Vector2i(first_x, y)
				if cand.has(pos) and level.region_at(first_x, y) != r:
					cand.erase(pos)
					changed = true

	# (c) Row/Col-Region interaction
	# "If all candidates in a row (without pieces) are in one region, eliminate candidates in that region outside the row"
	for y in range(h):
		var has_piece = false
		for p in pieces:
			if p.y == y:
				has_piece = true
				break
		if has_piece:
			continue
			
		var row_cands = []
		for x in range(w):
			var pos = Vector2i(x, y)
			if cand.has(pos):
				row_cands.append(pos)
				
		if row_cands.is_empty():
			continue
			
		# Check if all candidates are in the same region
		var first_r = level.region_at(row_cands[0].x, row_cands[0].y)
		var all_same_region = true
		for c in row_cands:
			if level.region_at(c.x, c.y) != first_r:
				all_same_region = false
				break
				
		if all_same_region:
			# Eliminate candidates in this region that are NOT in this row
			for cy in range(h):
				if cy == y: continue
				for cx in range(w):
					if level.region_at(cx, cy) == first_r:
						var pos = Vector2i(cx, cy)
						if cand.has(pos):
							cand.erase(pos)
							changed = true

	# Same for Columns
	for x in range(w):
		var has_piece = false
		for p in pieces:
			if p.x == x:
				has_piece = true
				break
		if has_piece:
			continue
			
		var col_cands = []
		for y in range(h):
			var pos = Vector2i(x, y)
			if cand.has(pos):
				col_cands.append(pos)
				
		if col_cands.is_empty():
			continue
			
		# Check if all candidates are in the same region
		var first_r = level.region_at(col_cands[0].x, col_cands[0].y)
		var all_same_region = true
		for c in col_cands:
			if level.region_at(c.x, c.y) != first_r:
				all_same_region = false
				break
				
		if all_same_region:
			# Eliminate candidates in this region that are NOT in this column
			for cy in range(h):
				for cx in range(w):
					if cx == x: continue
					if level.region_at(cx, cy) == first_r:
						var pos = Vector2i(cx, cy)
						if cand.has(pos):
							cand.erase(pos)
							changed = true
							
	return changed

static func place(level, cand: Dictionary, pieces: Array, p: Vector2i) -> void:
	pieces.append(p)
	if cand.has(p):
		cand.erase(p)
		
	var w = level.width
	var h = level.height
	
	# Remove candidates in same row
	for x in range(w):
		var pos = Vector2i(x, p.y)
		if cand.has(pos):
			cand.erase(pos)
			
	# Remove candidates in same column
	for y in range(h):
		var pos = Vector2i(p.x, y)
		if cand.has(pos):
			cand.erase(pos)
			
	# Remove candidates in same region
	var r = level.region_at(p.x, p.y)
	for y in range(h):
		for x in range(w):
			if level.region_at(x, y) == r:
				var pos = Vector2i(x, y)
				if cand.has(pos):
					cand.erase(pos)
					
	# Remove candidates in surrounding 8 cells
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0: continue
			var nx = p.x + dx
			var ny = p.y + dy
			if nx < 0 or nx >= w or ny < 0 or ny >= h: continue
			var pos = Vector2i(nx, ny)
			if cand.has(pos):
				cand.erase(pos)
