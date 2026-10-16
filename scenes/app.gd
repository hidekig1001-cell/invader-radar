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


func chosen_language() -> String:
	if title_screen != null and title_screen.has_method("language"):
		var lang = title_screen.language()
		if lang == "":
			return "en"
		return lang
	return "en"


func start_game(with_tutorial: bool) -> void:
	var lang = chosen_language()
	if title_screen != null:
		title_screen.queue_free()
		title_screen = null
	main = MainScene.instantiate()
	main.start_with_tutorial = with_tutorial
	main.language = lang
	main.title_requested.connect(show_title)
	add_child(main)


func show_title() -> void:
	if main != null:
		main.queue_free()
		main = null
	title_screen = TitleScreen.new()
	title_screen.start_requested.connect(start_game)
	add_child(title_screen)
