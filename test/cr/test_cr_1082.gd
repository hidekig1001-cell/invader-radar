extends GutTest

const MainScene = preload("res://scenes/main.tscn")


class FakeStore:
	var saved: Dictionary = {}

	func load_progress() -> Dictionary:
		return {"level_index": 2, "score": 30, "hints": 1}

	func save_progress(data: Dictionary) -> void:
		saved = data


## CHECK: 1
func test_cr1082_1_progress_store_roundtrip_and_empty_path() -> void:
	var StoreScript = load("res://game/progress_store.gd")
	assert_not_null(StoreScript, "ProgressStore script should exist")

	var store = StoreScript.new()
	store.path = "user://test_cr_1082.json"

	store.clear()
	assert_eq(store.load_progress(), {}, "After clear, load_progress should return empty dict")

	store.save_progress({"level_index": 2, "score": 5, "hints": 1})
	var loaded = store.load_progress()
	assert_eq(loaded["score"], 5, "Saved score should be retrievable")

	store.clear()
	assert_eq(store.load_progress(), {}, "After second clear, load_progress should return empty dict")

	var empty_store = StoreScript.new()
	empty_store.save_progress({"level_index": 2, "score": 5, "hints": 1})
	assert_eq(empty_store.load_progress(), {}, "Save with empty path should not persist data")


## CHECK: 2
func test_cr1082_2_main_uses_injected_store() -> void:
	var fake = FakeStore.new()
	var m = MainScene.instantiate()
	m.save_path = "user://test_cr_1082_unused.json"
	m.progress_store = fake
	add_child_autofree(m)
	await wait_frames(2)

	assert_eq(m.session.level_index, 2, "Session level_index should be loaded from fake store")
	assert_eq(m.session.score, 30, "Session score should be loaded from fake store")

	m.save_progress()
	assert_eq(fake.saved["score"], 30, "Saved score in fake store should match session score")
	assert_eq(fake.saved["level_index"], 2, "Saved level_index in fake store should match session level_index")
