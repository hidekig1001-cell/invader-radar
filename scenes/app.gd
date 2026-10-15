extends Node

const MainScene = preload("res://scenes/main.tscn")
const TitleScreen = preload("res://scenes/title_screen.gd")
const SEEN_PATH := "user://tutorial_seen"

var main = null
var title_screen = null


func _ready() -> void:
	title_screen = TitleScreen.new()
	title_screen.start_requested.connect(start_game)
	add_child(title_screen)


func start_game(with_tutorial: bool) -> void:
	if title_screen != null:
		title_screen.queue_free()
		title_screen = null
	main = MainScene.instantiate()
	main.start_with_tutorial = with_tutorial
	add_child(main)
