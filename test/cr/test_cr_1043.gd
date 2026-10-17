extends GutTest

const MainScene = preload("res://scenes/main.tscn")
const BoardState = preload("res://core/board_state.gd")
const TutorialSteps = preload("res://game/tutorial_steps.gd")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_to_board_pos_transforms_coordinates() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	var result = m.to_board_pos(Vector2(165, 857))
	assert_eq(result, Vector2(165, 605))


## CHECK: 2
func test_is_on_board_checks_bounds() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	assert_true(m.is_on_board(Vector2(165, 857)))
	assert_false(m.is_on_board(Vector2(165, 605)))


## CHECK: 3
func test_touch_down_up_marks_correct_cell() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	
	# Tap at screen pos (165, 857) which maps to board pos (165, 605) -> Cell (0,0)
	m._on_touch_down(Vector2(165, 857))
	m._on_touch_up(Vector2(165, 857))
	
	assert_eq(m.session.board.state_at(0, 0), BoardState.MARK)
	assert_eq(m.session.board.state_at(0, 1), BoardState.EMPTY)
	
	# Tap at screen pos (165, 605) which maps to board pos (165, 353) -> Outside board or different cell?
	# CR says: "m._on_touch_down(Vector2(165, 605)) ... state_at(0, 0) is MARK ... state_at(0, 1) is EMPTY"
	# This implies the second tap does NOT change the state of (0,0) or (0,1).
	# If (165, 605) maps to a valid cell, it might mark that cell. But the assertion checks (0,0) and (0,1).
	# Let's assume the second tap is either outside or on a different cell that doesn't affect these assertions.
	m._on_touch_down(Vector2(165, 605))
	m._on_touch_up(Vector2(165, 605))
	
	assert_eq(m.session.board.state_at(0, 0), BoardState.MARK)
	assert_eq(m.session.board.state_at(0, 1), BoardState.EMPTY)


## CHECK: 4
func test_double_tap_places_piece() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	
	# Screen pos (915, 1107). 
	# Offset for 1080x2424 vs 1080x1920: extra_y = (2424-1920)/2 = 252.
	# Board view base pos likely (40, 480) or similar. 
	# CR says this maps to Cell (3,1).
	m._on_touch_down(Vector2(915, 1107))
	m._on_touch_up(Vector2(915, 1107))
	
	# Double tap requires two taps within time limit.
	# The first tap above sets _prev_tap.
	# We need to simulate the second tap quickly.
	m._on_touch_down(Vector2(915, 1107))
	m._on_touch_up(Vector2(915, 1107))
	
	assert_eq(m.session.board.state_at(3, 1), BoardState.PIECE)


## CHECK: 5
func test_drag_stroke_marks_cells() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	
	# Start at (165, 857) -> Board (165, 605) -> Cell (0,0)
	m._on_touch_down(Vector2(165, 857))
	
	# Drag to (415, 857). 
	# Screen X diff = 250. Board cell size approx 250? 
	# CR says state_at(1,0) becomes MARK. So (415, 857) maps to Cell (1,0).
	var drag_event = InputEventScreenDrag.new()
	drag_event.index = 0
	drag_event.position = Vector2(415, 857)
	m._input(drag_event)
	
	# End at (415, 857)
	m._on_touch_up(Vector2(415, 857))
	
	assert_eq(m.session.board.state_at(0, 0), BoardState.MARK)
	assert_eq(m.session.board.state_at(1, 0), BoardState.MARK)
	assert_eq(m.session.moves, 1)


## CHECK: 6
func test_is_on_board_false_outside() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1440, 1920))
	
	# CR says (215, 605) is NOT on board.
	m._on_touch_down(Vector2(215, 605))
	m._on_touch_up(Vector2(215, 605))
	assert_eq(m.session.board.state_at(0, 0), BoardState.EMPTY)
	
	# CR says (345, 605) maps to (165, 605) which IS on board -> Cell (0,0).
	m._on_touch_down(Vector2(345, 605))
	m._on_touch_up(Vector2(345, 605))
	assert_eq(m.session.board.state_at(0, 0), BoardState.MARK)


## CHECK: 7
func test_tutorial_input_transforms_coordinates() -> void:
	var m = await _start()
	m.apply_screen_layout(Vector2(1080, 2424))
	m.start_tutorial()
	
	# Initial text should be step 0
	assert_eq(m.bubble.text, TutorialSteps.steps()[0]["text"])
	
	# Tap at (165, 857) -> Board (165, 605). 
	# CR says this keeps bubble text as step 0.
	m._on_touch_down(Vector2(165, 857))
	m._on_touch_up(Vector2(165, 857))
	assert_eq(m.bubble.text, TutorialSteps.steps()[0]["text"])
	
	# Double tap at (915, 1107) -> Board (915, 855) -> Cell (3, 1).
	# Step 0 waits for double_tap on cell (3, 1).
	m._on_touch_down(Vector2(915, 1107))
	m._on_touch_up(Vector2(915, 1107))
	m._on_touch_down(Vector2(915, 1107))
	m._on_touch_up(Vector2(915, 1107))
	assert_eq(m.bubble.text, TutorialSteps.steps()[1]["text"])

