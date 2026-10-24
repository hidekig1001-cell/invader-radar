extends GutTest

const Sound = preload("res://scenes/sound.gd")
const MainScene = preload("res://scenes/main.tscn")
const TitleScreenScript = preload("res://scenes/title_screen.gd")


func _start_main():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _start_title():
	var ts = TitleScreenScript.new()
	add_child_autofree(ts)
	await wait_frames(2)
	return ts


## CHECK: 1
func test_sfx_for_mark() -> void:
	var prev = {"status": "playing", "board": {"marks": 0, "pieces": 0}}
	var curr = {"status": "playing", "board": {"marks": 1, "pieces": 0}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 0), "mark")


## CHECK: 2
func test_sfx_for_place() -> void:
	var prev = {"status": "playing", "board": {"marks": 0, "pieces": 0}}
	var curr = {"status": "playing", "board": {"marks": 0, "pieces": 1}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 0), "place")


## CHECK: 3
func test_sfx_for_clear() -> void:
	var prev = {"status": "playing", "board": {"marks": 0, "pieces": 1}}
	var curr = {"status": "playing", "board": {"marks": 0, "pieces": 0}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 0), "clear")


## CHECK: 4
func test_sfx_for_hint() -> void:
	var prev = {"status": "playing", "hints": 3, "board": {"marks": 0, "pieces": 0}}
	var curr = {"status": "playing", "hints": 2, "board": {"marks": 0, "pieces": 0}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 0), "hint")


## CHECK: 5
func test_sfx_for_wrong() -> void:
	var prev = {"status": "playing", "board": {"marks": 0, "pieces": 1}}
	var curr = {"status": "playing", "board": {"marks": 0, "pieces": 1}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 1), "wrong")


## CHECK: 6
func test_sfx_for_level_clear() -> void:
	var prev = {"status": "playing", "board": {"marks": 0, "pieces": 1}}
	var curr = {"status": "cleared", "board": {"marks": 0, "pieces": 1}}
	assert_eq(Sound.sfx_for(prev, curr, 0, 0), "level_clear")


## CHECK: 7
func test_main_music_setup() -> void:
	var m = await _start_main()
	assert_eq(m.sound.music_name, "bgm_stage1")
	assert_eq(m.sound.music_player.volume_db, -8.0)


## CHECK: 8
func test_main_played_mark_on_tap() -> void:
	var m = await _start_main()
	m.session.tap(0, 0)
	await wait_frames(1)
	assert_eq(m.sound.played[-1], "mark")


## CHECK: 9
func test_button_sfx_in_main_and_title() -> void:
	var m = await _start_main()
	m.hud.undo_pressed.emit()
	await wait_frames(1)
	assert_eq(m.sound.played[-1], "button")

	var ts = await _start_title()
	ts._lang_btn_en.pressed.emit()
	await wait_frames(1)
	assert_eq(ts.sound.played[-1], "button")


## CHECK: 10
func test_title_music_lifecycle() -> void:
	var ts = await _start_title()
	assert_eq(ts.sound.music_name, "bgm_title")
	ts.press_start(true)
	await wait_frames(1)
	assert_eq(ts.sound.music_name, "")
