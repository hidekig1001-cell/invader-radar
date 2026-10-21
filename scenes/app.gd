extends Node

const MainScene = preload("res://scenes/main.tscn")
const TitleScreen = preload("res://scenes/title_screen.gd")
const SplashScreen = preload("res://scenes/splash_screen.gd")
const SessionSave = preload("res://game/session_save.gd")
const ProgressStore = preload("res://game/progress_store.gd")
const CloudStore = preload("res://scenes/cloud_store.gd")
const SEEN_PATH := "user://tutorial_seen"
const SAVE_PATH := "user://progress.json"

var main = null
var title_screen = null
var splash = null
var save_path := SAVE_PATH
var cloud_config_path: String = ""
var cloud_store = null


func _ready() -> void:
	splash = SplashScreen.new()
	add_child(splash)
	splash.finished.connect(on_splash_finished)


func chosen_language() -> String:
	if title_screen != null and title_screen.has_method("language"):
		var lang = title_screen.language()
		if lang == "":
			return "en"
		return lang
	return "en"


func on_splash_finished() -> void:
	if splash == null:
		return
	splash.queue_free()
	splash = null
	title_screen = TitleScreen.new()
	title_screen.start_requested.connect(start_game)
	title_screen.fresh_start_requested.connect(start_fresh_game)
	title_screen.quit_requested.connect(quit_app)
	add_child(title_screen)


func make_store():
	if cloud_store == null:
		cloud_store = CloudStore.new()
		cloud_store.config_path = cloud_config_path
		add_child(cloud_store)
	if not cloud_store.is_configured():
		return null
	var local = ProgressStore.new()
	local.path = save_path
	cloud_store.local_store = local
	return cloud_store


func start_game(with_tutorial: bool) -> void:
	if splash != null:
		splash.queue_free()
		splash = null
	var lang = chosen_language()
	if title_screen != null:
		title_screen.queue_free()
		title_screen = null
	main = MainScene.instantiate()
	main.start_with_tutorial = with_tutorial
	main.language = lang
	main.save_path = save_path
	main.progress_store = make_store()
	main.title_requested.connect(show_title)
	add_child(main)


func start_fresh_game() -> void:
	var store = ProgressStore.new()
	store.path = save_path
	store.clear()
	start_game(false)


func show_title() -> void:
	if main != null:
		main.queue_free()
		main = null
	title_screen = TitleScreen.new()
	title_screen.start_requested.connect(start_game)
	title_screen.fresh_start_requested.connect(start_fresh_game)
	title_screen.quit_requested.connect(quit_app)
	add_child(title_screen)


func quit_app() -> void:
	get_tree().quit()
