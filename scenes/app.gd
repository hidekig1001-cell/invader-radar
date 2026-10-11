# 画面の層（SPEC.md 3 節）: アプリの起動のシーン。main.tscn を立ち上げる前に、チュートリアルを見せるかを決める。
# チュートリアルは初めて立ち上げたときだけ見せる（10/11 ユーザーの決定 A3）。見終えたら user:// に印を書く。
# テストと撮影（.autedev/shot.gd）は main.tscn をそのまま立ち上げるので、チュートリアルは出ない（CR-1012）。
# ファイルの読み書きは改修 run の禁止 API なので、このファイルは Opus が改修 run の外で直す。
extends Node

const MainScene = preload("res://scenes/main.tscn")
const SEEN_PATH := "user://tutorial_seen"

var main = null


func _ready() -> void:
	main = MainScene.instantiate()
	main.start_with_tutorial = not FileAccess.file_exists(SEEN_PATH)
	main.tutorial_finished.connect(_on_tutorial_finished)
	add_child(main)


func _on_tutorial_finished() -> void:
	var f := FileAccess.open(SEEN_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string("1")
		f.close()
