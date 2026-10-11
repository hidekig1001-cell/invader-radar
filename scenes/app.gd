# 画面の層（SPEC.md 3 節）: アプリの起動のシーン。main.tscn を立ち上げる前に、チュートリアルを見せる印を入れる。
# テストと撮影（.autedev/shot.gd）は main.tscn をそのまま立ち上げるので、チュートリアルは出ない（CR-1012）。
extends Node

const MainScene = preload("res://scenes/main.tscn")

var main = null


func _ready() -> void:
	main = MainScene.instantiate()
	main.start_with_tutorial = true
	add_child(main)
