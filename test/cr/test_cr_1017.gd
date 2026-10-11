extends GutTest

const Session = preload("res://game/session.gd")

func _make_session() -> Session:
	var s = Session.new()
	return s

## CHECK: 1
func test_cr_1017_hints_increase_on_clear_from_1_to_2() -> void:
	var s = _make_session()
	# hints starts at 3 (DEFAULT_HINTS)
	assert_eq(s.hints, 3)
	s.use_hint()
	s.use_hint()
	assert_eq(s.hints, 1)
	
	# Solve level 1: pieces at (1,0), (3,1), (0,2), (2,3)
	s.double_tap(1, 0)
	s.double_tap(3, 1)
	s.double_tap(0, 2)
	s.double_tap(2, 3)
	
	assert_eq(s.status, "cleared")
	assert_eq(s.hints, 2)

## CHECK: 2
func test_cr_1017_hints_increase_on_clear_from_0_to_1_and_not_on_next_level() -> void:
	var s = _make_session()
	# hints starts at 3
	s.use_hint()
	s.use_hint()
	s.use_hint()
	assert_eq(s.hints, 0)
	
	# Solve level 1
	s.double_tap(1, 0)
	s.double_tap(3, 1)
	s.double_tap(0, 2)
	s.double_tap(2, 3)
	
	assert_eq(s.status, "cleared")
	assert_eq(s.hints, 1)
	
	# Next level should not increase hints further
	s.next_level()
	assert_eq(s.hints, 1)
