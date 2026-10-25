extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const BoardView = preload("res://scenes/board_view.gd")

func _setup_board_view() -> BoardView:
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"radar": [[0, 0, 1]], 
		"asteroids": [[3, 3]], 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]
	})
	var s = SessionScript.new([level])
	var bv = BoardView.new()
	add_child_autofree(bv)
	bv.session = s
	return bv

## CHECK: 1
func test_rock_image_at_returns_true_for_radar_and_asteroid_cells() -> void:
	var bv = _setup_board_view()
	# (0,0) has radar, so rock_image_at should be true
	assert_true(bv.rock_image_at(0, 0))
	# (3,3) is an asteroid, so rock_image_at should be true
	assert_true(bv.rock_image_at(3, 3))
	# (1,1) has neither radar nor asteroid, so rock_image_at should be false
	assert_false(bv.rock_image_at(1, 1))
	# (0,0) is a radar cell, not an asteroid, so is_rock should be false
	assert_false(bv.is_rock(0, 0))
