extends SceneTree
# 改修 run の撮影用 SceneTree スクリプト（このアプリ用。設計書 4 章）。入力と同じ session の操作だけで場面を作る。
# 引数は improve/godot_scripts/shot.gd と同じ: --out=<png> --frames=<n> --scenario=idle|play
#   --scenario=idle : 面の始めのまま、--frames フレーム後に撮る
#   --scenario=play : 5 フレーム目に (0,0) と (3,3) を tap（×）、(1,3) を double_tap（駒）し、--frames フレーム後（最低 10）に撮る
var frames := 0
var out_path := ""
var wait_frames := 90
var scenario := "idle"
var inst = null


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
		elif a.begins_with("--frames="):
			wait_frames = int(a.substr(9))
		elif a.begins_with("--scenario="):
			scenario = a.substr(11)
	var scene: PackedScene = load("res://scenes/main.tscn")
	inst = scene.instantiate()
	root.add_child(inst)


func _state() -> Dictionary:
	var b: Dictionary = inst.session.snapshot()["board"]
	return {"marks": b["marks"], "pieces": b["pieces"]}


func _process(_delta: float) -> bool:
	frames += 1
	if scenario == "play" and frames == 5:
		inst.session.tap(0, 0)
		inst.session.tap(3, 3)
		inst.session.double_tap(1, 3)
	if frames >= (maxi(wait_frames, 10) if scenario == "play" else wait_frames):
		_capture(_state())
	return false


func _capture(st: Dictionary) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	var nonblack := 0
	var total := 0
	for y in range(0, img.get_height(), 3):
		for x in range(0, img.get_width(), 3):
			total += 1
			var c := img.get_pixel(x, y)
			if c.r + c.g + c.b > 0.35:
				nonblack += 1
	print("SHOT saved err=", err, " size=", img.get_size(), " bright=", nonblack, " of ", total, " frames=", frames,
		" marks=", st["marks"], " pieces=", st["pieces"])
	quit(0)
