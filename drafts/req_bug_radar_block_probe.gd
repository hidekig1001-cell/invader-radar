extends GutTest
# 数字付きの岩（レーダー）に × も宇宙人も付けられないようにする直しの確かめる項目を GUT にした見本（req_bug_radar_block.txt の項目 1〜3 と同じ順）。
# main 0ae3435 で流す。直しなし（今の main）では 3 関数とも落ち、try_bug_radar_block_patch.py を当てた写しでは通る見込み（このクラウドには Godot が無く、流してはいない）。


func _session():
	var Level = load("res://game/level.gd")
	var SessionScript = load("res://game/session.gd")
	var level = Level.new()
	level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]})
	return SessionScript.new([level])


## CHECK: 1
func test_is_radar() -> void:
	var s = _session()
	assert_eq(s.is_radar(0, 0), true)
	assert_eq(s.is_radar(1, 0), false)
	assert_eq(s.is_radar(3, 3), false)


## CHECK: 2
func test_tap_and_double_tap_on_radar() -> void:
	var s = _session()
	assert_eq(s.tap(0, 0), false)
	assert_eq(s.double_tap(0, 0), false)
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.moves, 0)
	assert_eq(s.tap(1, 0), true)
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.moves, 1)


## CHECK: 3
func test_swipe_over_radar() -> void:
	var s = _session()
	assert_eq(s.swipe([Vector2i(0, 0)]), false)
	assert_eq(s.moves, 0)
	assert_eq(s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]), true)
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.board.state_at(2, 0), 1)
	assert_eq(s.moves, 1)
