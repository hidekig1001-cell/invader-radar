extends RefCounted

const TutorialSteps = preload("res://game/tutorial_steps.gd")
const Session = preload("res://game/session.gd")
const Level = preload("res://game/level.gd")

var session = null
var step_index: int = 0


func _init() -> void:
	var steps = TutorialSteps.steps()
	var level_data = TutorialSteps.practice_level()
	var level = Level.new()
	level.parse(level_data)
	session = Session.new([level])
	step_index = 0


func current_step() -> Dictionary:
	if is_finished():
		return {}
	var steps = TutorialSteps.steps()
	return steps[step_index]


func is_finished() -> bool:
	var steps = TutorialSteps.steps()
	return step_index >= steps.size()


func step_has_mark_cells() -> bool:
	if is_finished():
		return false
	var step = current_step()
	var wait = step["wait"]
	return wait["kind"] == "mark"


func marks_covered(cells: Array) -> bool:
	var board_marks = session.board.marks()
	for cell in cells:
		if not board_marks.has(cell):
			return false
	return true


func handle(kind: String, cell: Vector2i) -> bool:
	if is_finished():
		return false
	
	var step = current_step()
	var wait = step["wait"]
	var wait_kind = wait["kind"]
	
	match wait_kind:
		"double_tap":
			if kind == "double_tap" and cell == wait["cell"]:
				session.double_tap(cell.x, cell.y)
				step_index += 1
				return true
			return false
		"tap":
			if kind == "tap" and cell == wait["cell"]:
				session.tap(cell.x, cell.y)
				step_index += 1
				return true
			return false
		"next":
			if kind == "next":
				step_index += 1
				return true
			return false
		"solved":
			if kind == "tap":
				session.tap(cell.x, cell.y)
				if session.status == "cleared":
					step_index += 1
				return true
			elif kind == "double_tap":
				session.double_tap(cell.x, cell.y)
				if session.status == "cleared":
					step_index += 1
				return true
			else:
				return false
		"mark":
			if kind == "tap":
				session.tap(cell.x, cell.y)
				var mark_cells = wait.get("cells", TutorialSteps.mark_cells())
				if marks_covered(mark_cells):
					step_index += 1
				return true
			elif kind == "double_tap":
				return false
			else:
				return false
	
	return false
