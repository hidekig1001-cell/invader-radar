extends RefCounted

const LevelMaker = preload("res://game/level_maker.gd")
const Level = preload("res://game/level.gd")
const Solver = preload("res://core/solver.gd")

var task_id: int = -1
var pending_index: int = -1
var holder: Dictionary = {}


static func build(width: int, seed: int, radar: int, asteroids: int) -> Dictionary:
	var dict = LevelMaker.make_level(width, width, seed, radar, asteroids)
	var solution: Array = []
	if width >= 6:
		var lv = Level.new()
		if lv.parse(dict):
			var sols = Solver.solutions(lv, 1)
			if not sols.is_empty():
				solution = sols[0]
	return {"level": dict, "solution": solution}


static func build_into(box: Dictionary, width: int, seed: int, radar: int, asteroids: int) -> void:
	box["result"] = build(width, seed, radar, asteroids)


func start(index: int, width: int, seed: int, radar: int, asteroids: int) -> void:
	if task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(task_id)
	holder = {}
	pending_index = index
	task_id = WorkerThreadPool.add_task(Callable(get_script(), "build_into").bind(holder, width, seed, radar, asteroids))


func take(index: int) -> Dictionary:
	if task_id < 0:
		return {}
	WorkerThreadPool.wait_for_task_completion(task_id)
	task_id = -1
	if pending_index != index:
		pending_index = -1
		return {}
	pending_index = -1
	return holder.get("result", {})
