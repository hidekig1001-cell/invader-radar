extends RefCounted

const BoardState = preload("res://core/board_state.gd")

static func next_hint(board_state, level) -> Dictionary:
	if board_state == null or level == null:
		return {}
	
	var solutions = preload("res://core/solver.gd").solutions(level, 1)
	if solutions.is_empty():
		return {}
	
	var solution = solutions[0]
	var solution_set = {}
	for cell in solution:
		solution_set[cell] = true
	
	# 1. Check for wrong marks (marks on solution cells)
	var wrong_marks = []
	for cell in solution:
		if board_state.state_at(cell.x, cell.y) == BoardState.MARK:
			wrong_marks.append(cell)
	
	if not wrong_marks.is_empty():
		wrong_marks.sort_custom(func(a, b): 
			if a.y != b.y: return a.y < b.y
			return a.x < b.x
		)
		var cell = wrong_marks[0]
		return {
			"cell": cell,
			"kind": "wrong_mark",
			"text": "THIS CELL IS MARKED BY MISTAKE. TAP TO REMOVE THE X."
		}
	
	# 2. Check for wrong pieces (pieces not in solution)
	var wrong_pieces = []
	for piece in board_state.pieces():
		if not solution_set.has(piece):
			wrong_pieces.append(piece)
	
	if not wrong_pieces.is_empty():
		wrong_pieces.sort_custom(func(a, b): 
			if a.y != b.y: return a.y < b.y
			return a.x < b.x
		)
		var cell = wrong_pieces[0]
		return {
			"cell": cell,
			"kind": "wrong_piece",
			"text": "THIS PIECE IS IN THE WRONG PLACE. DOUBLE TAP TO REMOVE IT."
		}
	
	# 3. Check for next piece (solution cells without pieces)
	var next_pieces = []
	for cell in solution:
		if board_state.state_at(cell.x, cell.y) != BoardState.PIECE:
			next_pieces.append(cell)
	
	if not next_pieces.is_empty():
		next_pieces.sort_custom(func(a, b): 
			if a.y != b.y: return a.y < b.y
			return a.x < b.x
		)
		var cell = next_pieces[0]
		return {
			"cell": cell,
			"kind": "next_piece",
			"text": "A PIECE GOES HERE. DOUBLE TAP TO PLACE IT."
		}
	
	return {}
