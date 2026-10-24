extends GutTest

const TitleScreenScript = preload("res://scenes/title_screen.gd")


func _start():
	var ts = TitleScreenScript.new()
	add_child_autofree(ts)
	await wait_frames(2)
	return ts


## CHECK: 1
func test_background_is_texture_rect_with_correct_size() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	assert_true(ts.background is TextureRect)
	var tex = ts.background.texture
	assert_not_null(tex)
	assert_eq(tex.get_width(), 1080)
	assert_eq(tex.get_height(), 1920)


## CHECK: 2
func test_background_texture_path() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	var tex = ts.background.texture
	assert_not_null(tex)
	assert_true(tex.resource_path.contains("assets/title_bg_1080x1920.png"))


## CHECK: 3
func test_background_global_rect_is_full_screen() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	var expected = Rect2(0, 120, 1080, 1920)
	var actual = ts.background.get_global_rect()
	assert_true(actual.is_equal_approx(expected))


## CHECK: 4
func test_background_is_visible() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	assert_true(ts.background.visible)


## CHECK: 5
func test_background_is_first_child() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	assert_eq(ts.get_child(0), ts.background)


## CHECK: 6
func test_background_encloses_all_widgets() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	var bg_rect = Rect2(0, 0, 1080, 1920)
	
	# Check title label
	var title_rect = ts._title_label.get_global_rect()
	assert_true(bg_rect.encloses(title_rect))
	
	# Check language buttons
	var lang_en_rect = ts._lang_btn_en.get_global_rect()
	assert_true(bg_rect.encloses(lang_en_rect))
	var lang_ja_rect = ts._lang_btn_ja.get_global_rect()
	assert_true(bg_rect.encloses(lang_ja_rect))
	
	# Check start buttons (need to make them visible first to get valid rects, or check position/size directly if hidden)
	# Since they are initially hidden, get_global_rect might be empty or zero. 
	# The CR says "parts are placed on top of background". We should ensure their intended positions are within bounds.
	# However, the test asks for get_global_rect(). If hidden, it might not report correctly depending on Godot version.
	# Let's force them visible to check layout, or check their position/size properties which define the rect.
	# The CR item 6 says "background ... encloses ... get_global_rect()". 
	# If buttons are hidden, they might not have a valid global rect in some contexts, but usually Control nodes do.
	# Let's assume we can check them. If they are hidden, their rect is still defined by position/size.
	
	var start_tut_rect = ts._start_btn_tutorial.get_global_rect()
	assert_true(bg_rect.encloses(start_tut_rect))
	
	var start_now_rect = ts._start_btn_now.get_global_rect()
	assert_true(bg_rect.encloses(start_now_rect))


## CHECK: 7
func test_screen_size_and_background_position_size_unchanged() -> void:
	var ts = await _start()
	assert_not_null(ts.background)
	
	# Title screen size should remain 1080x1920
	assert_true(ts.size.is_equal_approx(Vector2(1080, 1920)))
	
	# Background position and size
	assert_true(ts.background.position.is_equal_approx(Vector2(0, 120)))
	assert_true(ts.background.size.is_equal_approx(Vector2(1080, 1920)))
