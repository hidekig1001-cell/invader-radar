extends Node

const SFX_PLACE := preload("res://assets/audio/place.wav")
const SFX_MARK := preload("res://assets/audio/mark.wav")
const SFX_CLEAR := preload("res://assets/audio/clear.wav")
const SFX_HINT := preload("res://assets/audio/hint.wav")
const SFX_WRONG := preload("res://assets/audio/wrong.wav")
const SFX_LEVEL_CLEAR := preload("res://assets/audio/level_clear.wav")
const SFX_BUTTON := preload("res://assets/audio/button.wav")
const SFX_DEAD := preload("res://assets/audio/dead.wav")
const BGM_MAIN := preload("res://assets/audio/bgm_main.wav")
const BGM_TITLE := preload("res://assets/audio/bgm_title.wav")
const BGM_STAGE1 := preload("res://assets/audio/bgm_stage1.wav")
const BGM_STAGE2 := preload("res://assets/audio/bgm_stage2.wav")
const BGM_STAGE3 := preload("res://assets/audio/bgm_stage3.wav")
const BGM_STAGE4 := preload("res://assets/audio/bgm_stage4.wav")

var played: Array = []
var music_name: String = ""
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var vibrations: Array = []

func setup() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -8.0
	add_child(sfx_player)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -8.0
	add_child(music_player)

func play_sfx(sfx_name: String) -> void:
	var stream: AudioStream = null
	match sfx_name:
		"place":
			stream = SFX_PLACE
		"mark":
			stream = SFX_MARK
		"clear":
			stream = SFX_CLEAR
		"hint":
			stream = SFX_HINT
		"wrong":
			stream = SFX_WRONG
		"level_clear":
			stream = SFX_LEVEL_CLEAR
		"button":
			stream = SFX_BUTTON
		"dead":
			stream = SFX_DEAD
	if stream != null:
		sfx_player.stream = stream
		sfx_player.play()
		played.append(sfx_name)

func play_music(music: String) -> void:
	if music == music_name and music_player.playing:
		return
	var stream: AudioStream = null
	match music:
		"bgm_main":
			stream = BGM_MAIN
		"bgm_title":
			stream = BGM_TITLE
		"bgm_stage1":
			stream = BGM_STAGE1
		"bgm_stage2":
			stream = BGM_STAGE2
		"bgm_stage3":
			stream = BGM_STAGE3
		"bgm_stage4":
			stream = BGM_STAGE4
	if stream != null:
		music_player.stream = stream
		music_player.play()
		music_name = music

func stop_music() -> void:
	music_player.stop()
	music_name = ""

static func sfx_for(prev: Dictionary, curr: Dictionary, prev_conflicts: int, conflicts: int) -> String:
	var prev_board: Dictionary = prev.get("board", {})
	var curr_board: Dictionary = curr.get("board", {})
	var prev_marks: int = prev_board.get("marks", 0)
	var curr_marks: int = curr_board.get("marks", 0)
	var prev_pieces: int = prev_board.get("pieces", 0)
	var curr_pieces: int = curr_board.get("pieces", 0)
	var prev_hints: int = prev.get("hints", 0)
	var curr_hints: int = curr.get("hints", 0)
	var prev_status: String = prev.get("status", "")
	var curr_status: String = curr.get("status", "")

	if curr_status == "cleared" and prev_status == "playing":
		return "level_clear"
	if conflicts > prev_conflicts:
		return "wrong"
	if curr_hints < prev_hints:
		return "hint"
	if curr_pieces < prev_pieces:
		return "clear"
	if curr_pieces > prev_pieces:
		return "place"
	if curr_marks > prev_marks:
		return "mark"
	return ""

static func bgm_for_size(size: int) -> String:
	if size <= 5:
		return "bgm_stage1"
	elif size <= 7:
		return "bgm_stage2"
	elif size <= 9:
		return "bgm_stage3"
	else:
		return "bgm_stage4"

func vibrate(ms: int) -> void:
	vibrations.append(ms)
	Input.vibrate_handheld(ms)
