extends GutTest

class FakeHttp extends RefCounted:
	var urls: Array = []
	func request(url, headers, method, body) -> int:
		urls.append(url)
		return 0


func _make_app(config_data: Dictionary, config_path: String, save_path: String):
	var Save = load("res://game/session_save.gd")
	var AppScript = load("res://scenes/app.gd")
	var app = AppScript.new()
	app.cloud_config_path = config_path
	app.save_path = save_path
	Save.write_json(app.cloud_config_path, config_data)
	add_child_autofree(app)
	await wait_frames(2)
	return app


func test_cr1117_1_connect_pulled_and_no_pull_when_empty() -> void:
	## CHECK: 1
	var Save = load("res://game/session_save.gd")
	var app = await _make_app({"project_id": "p1", "web_api_key": "K"}, "user://test_cr_1117_config.json", "user://test_cr_1117_progress.json")
	app.make_store()
	app.cloud_store.state_path = "user://test_cr_1117_state.json"
	Save.write_json(app.cloud_store.state_path, {"rev": 1})
	var fake = FakeHttp.new()
	app.cloud_store.http = fake
	app.start_game(false)
	await wait_frames(2)
	assert_eq(fake.urls, [])
	assert_eq(app.cloud_store.pending, "")
	assert_true(app.cloud_store.pulled.is_connected(app.on_cloud_pulled))


func test_cr1117_2_pull_when_state_has_uid() -> void:
	## CHECK: 2
	var Save = load("res://game/session_save.gd")
	var app = await _make_app({"project_id": "p1", "web_api_key": "K"}, "user://test_cr_1117_config.json", "user://test_cr_1117_progress.json")
	app.make_store()
	app.cloud_store.state_path = "user://test_cr_1117_state.json"
	Save.write_json(app.cloud_store.state_path, {"rev": 1, "uid": "u9", "id_token": "t9", "refresh_token": "r9"})
	var fake = FakeHttp.new()
	app.cloud_store.http = fake
	app.start_game(false)
	await wait_frames(2)
	assert_eq(fake.urls, ["https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents/players/u9"])
	assert_eq(app.cloud_store.pending, "get")


func test_cr1117_3_on_cloud_pulled_restores_session() -> void:
	## CHECK: 3
	var app = await _make_app({}, "user://test_cr_1117_none.json", "user://test_cr_1117_progress2.json")
	app.start_game(false)
	await wait_frames(2)
	app.on_cloud_pulled({"level_index": 3, "score": 77, "hints": 1})
	assert_eq(app.main.session.level_index, 3)
	assert_eq(app.main.session.score, 77)
