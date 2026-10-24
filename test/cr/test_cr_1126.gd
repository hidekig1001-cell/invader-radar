extends GutTest

const Session = preload("res://game/session.gd")
const LevelPrefetch = preload("res://game/level_prefetch.gd")

## CHECK: 1
func test_prefetch_next_level() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 20, "score": 0, "hints": 3})
	assert_eq(s.prefetch.pending_index, 21)

	var r = RandomNumberGenerator.new()
	r.seed = 1
	r.randi() # discard first randi as per CR description
	var seed21 = r.randi()

	s.next_level()
	assert_eq(s.level_index, 21)

	var expected_build = LevelPrefetch.build(6, seed21, 5, 3)
	assert_eq(s.level.to_dict()["regions"], expected_build["level"]["regions"])
	assert_eq(s.given, expected_build["solution"][3])
	assert_eq(s.prefetch.pending_index, 22)

## CHECK: 2
func test_restart_level_preserves_prefetch() -> void:
	var s = Session.new()
	s.rng.seed = 1
	s.restore_dict({"level_index": 20, "score": 0, "hints": 3})

	var before_task_id = s.prefetch.task_id
	assert_eq(s.prefetch.pending_index, 21)

	s.restart_level()
	assert_eq(s.prefetch.task_id, before_task_id)
	assert_eq(s.prefetch.pending_index, 21)

	s.next_level()
	assert_eq(s.prefetch.pending_index, 22)

## CHECK: 3
func test_prefetch_conditions() -> void:
	var s = Session.new()
	# Default levels, index 0. Next is 1. 1 < 10, so no prefetch.
	assert_eq(s.prefetch.pending_index, -1)

	s.restore_dict({"level_index": 9, "score": 0, "hints": 3})
	# Index 9. Next is 10. 10 >= 10. Prefetch should start for 10.
	assert_eq(s.prefetch.pending_index, 10)

	var t = Session.new(Session.load_default_levels().slice(0, 3))
	t.next_level()
	# uses_default_levels is false because levels were passed in constructor.
	# prefetch_next checks uses_default_levels. If false, do nothing.
	assert_eq(t.prefetch.pending_index, -1)
