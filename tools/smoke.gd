extends SceneTree
# improve runner のスモークテスト用 SceneTree スクリプト: シーンを開いて --frames フレーム動かし、音を止めて実時間を空けてから終わる。
#   引数: --frames=<n>（既定 600）  --scene=<res://...>（既定 res://scenes/main.tscn）
# Godot 4.7.2 は、止めた・解放した音の再生（AudioStreamPlayback）を音声スレッドが次に回ったときに片付ける。
# 鳴らしたまま、または止めてすぐ終わると "resources still in use at exit"（AudioStreamWAV）が必ず出るが、アプリの誤りではない。
# そのためここで終わる前に音を止め、実時間で 150 ms 待つ（--fixed-fps ではゲーム時間のタイマーでは実時間が進まない）。
var n := 0
var limit := 600
var scene := "res://scenes/main.tscn"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--frames="):
			limit = int(a.substr(9))
		elif a.begins_with("--scene="):
			scene = a.substr(8)
	change_scene_to_file(scene)


func _process(_delta: float) -> bool:
	n += 1
	if n >= limit:
		for t in ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D"]:
			for p in root.find_children("*", t, true, false):
				p.stop()
		OS.delay_msec(150)
		return true
	return false
