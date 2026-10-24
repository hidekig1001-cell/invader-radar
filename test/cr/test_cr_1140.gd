extends GutTest

const Sound = preload("res://scenes/sound.gd")
const MainScene = preload("res://scenes/main.tscn")
const Level = preload("res://game/level.gd")


## CHECK: 1
func test_bgm_for_size() -> void:
	assert_eq(Sound.bgm_for_size(4), "bgm_stage1")
	assert_eq(Sound.bgm_for_size(5), "bgm_stage1")
	assert_eq(Sound.bgm_for_size(6), "bgm_stage2")
	assert_eq(Sound.bgm_for_size(7), "bgm_stage2")
	assert_eq(Sound.bgm_for_size(8), "bgm_stage3")
	assert_eq(Sound.bgm_for_size(9), "bgm_stage3")
	assert_eq(Sound.bgm_for_size(10), "bgm_stage4")


## CHECK: 2
func test_play_music_changes_stream() -> void:
	var snd = Sound.new()
	add_child_autofree(snd)
	snd.setup()

	snd.play_music("bgm_stage3")
	assert_eq(snd.music_name, "bgm_stage3")
	assert_eq(snd.music_player.stream.resource_path, "res://assets/audio/bgm_stage3.wav")

	snd.play_music("bgm_stage4")
	assert_eq(snd.music_name, "bgm_stage4")
	assert_eq(snd.music_player.stream.resource_path, "res://assets/audio/bgm_stage4.wav")


## CHECK: 3
func test_update_music_changes_bgm() -> void:
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)

	# Initial state: default level is 4x4, so bgm_stage1
	assert_eq(m.sound.music_name, "bgm_stage1")

	# Change level to 8x6 -> max is 8 -> bgm_stage3
	var lv = Level.new()
	lv.width = 8
	lv.height = 6
	m.session.level = lv
	m.update_music()
	assert_eq(m.sound.music_name, "bgm_stage3")

	# Change level to 10x10 -> max is 10 -> bgm_stage4
	lv.width = 10
	lv.height = 10
	m.update_music()
	assert_eq(m.sound.music_name, "bgm_stage4")
