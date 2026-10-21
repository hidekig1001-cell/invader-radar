extends GutTest

const Payload = preload("res://game/cloud_payload.gd")


## CHECK: 1
func test_signup_url() -> void:
	assert_eq(Payload.signup_url("K"), "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=K")


## CHECK: 1
func test_refresh_url() -> void:
	assert_eq(Payload.refresh_url("K"), "https://securetoken.googleapis.com/v1/token?key=K")


## CHECK: 1
func test_commit_url() -> void:
	assert_eq(Payload.commit_url("p1"), "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents:commit")


## CHECK: 1
func test_doc_name() -> void:
	assert_eq(Payload.doc_name("p1", "u1"), "projects/p1/databases/(default)/documents/players/u1")


## CHECK: 1
func test_doc_url() -> void:
	assert_eq(Payload.doc_url("p1", "u1"), "https://firestore.googleapis.com/v1/projects/p1/databases/(default)/documents/players/u1")


## CHECK: 2
func test_commit_body_structure() -> void:
	var fields = {"rev": {"integerValue": "3"}}
	var body = Payload.commit_body("p1", "u1", fields)
	assert_eq(body["writes"].size(), 1)
	var w = body["writes"][0]
	assert_eq(w["update"]["name"], "projects/p1/databases/(default)/documents/players/u1")
	assert_eq(w["update"]["fields"], fields)
	assert_eq(w["updateTransforms"], [{"fieldPath": "updated_at", "setToServerValue": "REQUEST_TIME"}])
