extends GutTest

const SpaceBg = preload("res://scenes/space_bg.gd")


## CHECK: 1
func test_safe_layout_offsets() -> void:
	# Case 1: safe_top=0, h=2424. base.y = (2424-1920)/2 = 252. extra = 504. y = max(252, 0-80) = 252. min(252, 504) = 252.
	var v1 = SpaceBg.safe_layout_offsets(1080, 2424, 0)
	assert_eq(v1, Vector2(0, 252))

	# Case 2: safe_top=300, h=2424. base.y = 252. extra = 504. y = max(252, 300-80) = 220. min(220, 504) = 220.
	# Wait, CR says: "Bg.safe_layout_offsets(1080, 2424, 300) も Vector2(0, 252)"
	# Let's re-read CR carefully.
	# "var y = max(base.y, safe_top - SAFE_TOP_MARGIN)" -> max(252, 300-80=220) = 252.
	# "Vector2(base.x, min(y, extra))" -> min(252, 504) = 252.
	# So it is 252. My manual calc was wrong in the comment above but correct in logic.
	var v2 = SpaceBg.safe_layout_offsets(1080, 2424, 300)
	assert_eq(v2, Vector2(0, 252))

	# Case 3: safe_top=200, h=2100. base.y = (2100-1920)/2 = 90. extra = 180. y = max(90, 200-80=120) = 120. min(120, 180) = 120.
	var v3 = SpaceBg.safe_layout_offsets(1080, 2100, 200)
	assert_eq(v3, Vector2(0, 120))

	# Case 4: safe_top=300, h=2000. base.y = (2000-1920)/2 = 40. extra = 80. y = max(40, 300-80=220) = 220. min(220, 80) = 80.
	var v4 = SpaceBg.safe_layout_offsets(1080, 2000, 300)
	assert_eq(v4, Vector2(0, 80))

	# Case 5: w=1440, h=1920, safe_top=300. base.x = (1440-1080)/2 = 180. base.y = 0. extra = 0. y = max(0, 300-80=220) = 220. min(220, 0) = 0.
	var v5 = SpaceBg.safe_layout_offsets(1440, 1920, 300)
	assert_eq(v5, Vector2(180, 0))


## CHECK: 2
func test_safe_top_for_layout() -> void:
	# Case 1: 150 * 2400 / 2400 = 150.0
	var v1 = SpaceBg.safe_top_for_layout(150, 2400, 2400)
	assert_almost_eq(v1, 150.0, 0.001)

	# Case 2: 100 * 2000 / 1000 = 200.0
	var v2 = SpaceBg.safe_top_for_layout(100, 1000, 2000)
	assert_almost_eq(v2, 200.0, 0.001)

	# Case 3: window_h <= 0 -> 0.0
	var v3 = SpaceBg.safe_top_for_layout(100, 0, 1920)
	assert_almost_eq(v3, 0.0, 0.001)
