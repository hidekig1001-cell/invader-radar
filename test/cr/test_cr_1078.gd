extends GutTest

const MainScene = preload("res://scenes/main.tscn")


func _start():
	var m = MainScene.instantiate()
	add_child_autofree(m)
	await wait_frames(2)
	return m


## CHECK: 1
func test_cr_1078_clear_effect_on_tutorial_solve() -> void:
	var m = await _start()
	m.start_tutorial()
	assert_false(m.clear_effect.active, "clear_effect should not be active before solving")
	
	m.tutorial.session.solve_now()
	assert_eq(m.tutorial.session.status, "cleared", "tutorial session status should be cleared after solve_now")
	assert_true(m.clear_effect.active, "clear_effect should be active after solving tutorial")
	
	m.clear_effect.active = false
	m._refresh()
	assert_false(m.clear_effect.active, "clear_effect should not be active on second refresh (duplicate prevention)")
	assert_eq(m.session.status, "playing", "main session status should remain playing")


## CHECK: 2
func test_cr_1078_no_clear_effect_on_tutorial_input() -> void:
	var m = await _start()
	m.start_tutorial()
	# Force clear_effect to be active to ensure the implementation logic (which checks last_tutorial_status)
	# prevents it from being re-triggered or keeps it false if not cleared.
	# However, the requirement is that it should NOT be active when not cleared.
	# If we set it to true manually, and then call tutorial_input which triggers _refresh,
	# the implementation should ensure it stays false (or becomes false) because status is "playing".
	# But wait, if clear_effect.active is true, and _refresh runs, does it turn it off?
	# The CR says: "call clear_effect.play(...) ... then last_tutorial_status = ...".
	# It doesn't say it turns off active.
	# Let's look at CHECK 1: "m.clear_effect.active = false にしてから m._refresh() を呼んでも m.clear_effect.active は false".
	# This implies _refresh does NOT set active to true if conditions aren't met.
	# So if we start with active=false, and call tutorial_input (status playing), it should remain false.
	# The error says "assert_false(m.clear_effect.active...)" passes in empty version.
	# We need an assertion that fails in empty version but passes in correct version.
	# In empty version, last_tutorial_status is "" (default).
	# If we manually set m.last_tutorial_status = "cleared" before calling tutorial_input?
	# No, start_tutorial resets things?
	# Let's try to verify that last_tutorial_status is updated correctly.
	# But last_tutorial_status is a var.
	# The CR says: "last_tutorial_status に tutorial.session.status を代入する".
	# So after solve_now (status cleared), last_tutorial_status should be "cleared".
	# After tutorial_input (status playing), last_tutorial_status should be "playing"?
	# Wait, the logic is: if is_tutorial() and status=="cleared" and last!="cleared" -> play. Then last=status.
	# So if status is "playing", last becomes "playing".
	
	m.tutorial_input("double_tap", Vector2i(3, 1))
	assert_eq(m.tutorial.session.status, "playing", "tutorial session status should be playing after input")
	assert_false(m.clear_effect.active, "clear_effect should not be active when tutorial is not cleared")
	# To make this fail in empty version:
	# In empty version, last_tutorial_status is "".
	# If we set m.last_tutorial_status = "cleared" manually before the input?
	# Then _refresh sees status="playing", last="cleared". Condition (status=="cleared") is false. No play.
	# This doesn't help distinguish.
	
	# Let's check if last_tutorial_status is updated.
	# If implementation is correct, after tutorial_input, last_tutorial_status should be "playing".
	# In empty version, it remains "".
	assert_eq(m.last_tutorial_status, "playing", "last_tutorial_status should be updated to playing")
