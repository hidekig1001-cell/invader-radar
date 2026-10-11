extends GutTest

const BoardView = preload("res://scenes/board_view.gd")
const Level = preload("res://game/level.gd")
const Session = preload("res://game/session.gd")


func _make_session_with_asteroids() -> Session:
	var lv = Level.new()
	lv.parse({
		"id": 1,
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]],
		"asteroids": [[1, 1], [3, 3]]
	})
	return Session.new([lv])


## CHECK: 1
func test_rock_rows_content() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	var expected := [
		"..1111..",
		".111211.",
		"11112111",
		"11211111",
		"11111121",
		"12111111",
		".111121.",
		"..1111.."
	]
	assert_eq(v.rock_rows(), expected)


## CHECK: 2
func test_is_rock_true_for_asteroid_cells() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = _make_session_with_asteroids()
	assert_true(v.is_rock(1, 1))
	assert_true(v.is_rock(3, 3))


## CHECK: 2
func test_is_rock_false_for_non_asteroid_cells() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = _make_session_with_asteroids()
	assert_false(v.is_rock(0, 0))
	assert_false(v.is_rock(3, 1))


## CHECK: 2
func test_is_rock_false_when_no_session() -> void:
	var v = BoardView.new()
	add_child_autofree(v)
	v.session = null
	assert_false(v.is_rock(1, 1))
