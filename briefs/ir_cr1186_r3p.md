# クラウドへの依頼: InvaderRadar改修1186 の R3'（テストを読む）（1 回目、2026-10-27 16:4x、Invader Radar30）

依頼と CR は branch review/cr1186-r0p の briefs/ir_cr1186_r0p.md（R0' は OK、results/cr1186_r0p.md）。main は 0ae3435（v1.94-cr1185）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183）。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値（is_radar の真偽、tap・double_tap・swipe の戻り値、盤の状態、手数）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（0ae3435）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1186-r3p のファイル results/cr1186_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1639-CR-1186
== tests/test_cr_1186.gd
extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")


func _make_session() -> SessionScript:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"asteroids": [[3, 3]],
		"radar": [[0, 0, 1]]
	})
	return SessionScript.new([level])


## CHECK: 1
func test_is_radar() -> void:
	var s = _make_session()
	assert_true(s.is_radar(0, 0))
	assert_false(s.is_radar(1, 0))
	assert_false(s.is_radar(3, 3))


## CHECK: 2
func test_tap_and_double_tap_on_radar() -> void:
	var s = _make_session()
	assert_false(s.tap(0, 0))
	assert_false(s.double_tap(0, 0))
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.moves, 0)
	
	assert_true(s.tap(1, 0))
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.moves, 1)


## CHECK: 3
func test_swipe_on_radar() -> void:
	var s = _make_session()
	assert_false(s.swipe([Vector2i(0, 0)]))
	assert_eq(s.moves, 0)
	
	assert_true(s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]))
	assert_eq(s.board.state_at(0, 0), 0)
	assert_eq(s.board.state_at(1, 0), 1)
	assert_eq(s.board.state_at(2, 0), 1)
	assert_eq(s.moves, 1)
== 既存のテストの書き直し
== 終わり
