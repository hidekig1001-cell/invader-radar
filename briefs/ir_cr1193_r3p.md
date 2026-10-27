# クラウドへの依頼: InvaderRadar改修1193 の R3'（テストを読む）（1 回目、2026-10-27 22:0x、Invader Radar31）

依頼と CR は branch review/cr1193-r0p の briefs/ir_cr1193_r0p.md（R0' は OK、results/cr1193_r0p.md）。main は 8111de3（v2.00-cr1192）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
この run は AuteDev の新しい版（release_52ef0ce）で流れた。材料に「注意（機械の印）」の節があれば、それも読んで、当たっているかを書く。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」・「数と各要素」に分けた形は NG（1183・1190）。まだ無い関数（rock_ng）をファイルの頭の preload の const から呼ぶと、ファイルごと Parse Error になり GUT が飛ばして「全部通過」に見える（1188）。rock_ng を呼ぶ所が関数の中の load か、場面を instantiate したものの上で呼んでいるかを見る。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜4 の手順と期待値（rock_ng の戻り値、played・vibrations の値まるごと、盤と手数が変わらない、ダブルタップで 1 回だけ、なぞりで鳴らない）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（8111de3）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1193-r3p のファイル results/cr1193_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-2156-CR-1193
== tests/test_cr_1193.gd
extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")


func _make_level() -> Level:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]],
		"radar": [[0, 0, 1]],
		"asteroids": [[3, 3]]
	})
	return level


func _make_main() -> Node:
	var m = MainScene.instantiate()
	m.session = SessionScript.new([_make_level()])
	add_child_autofree(m)
	await wait_frames(2)
	return m


func _cell_pos(m: Node, x: int, y: int) -> Vector2:
	return m.board_view.global_position + m.board_view.cell_rect(x, y).get_center()


func _touch_down(m: Node, pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = true
	ev.position = pos
	m._input(ev)


func _touch_up(m: Node, pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = false
	ev.position = pos
	m._input(ev)


## CHECK: 1
func test_cr_1193_check_1() -> void:
	var m = await _make_main()
	assert_eq(m.sound.played, [])
	assert_eq(m.sound.vibrations, [])

	assert_true(m.rock_ng(0, 0))
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])

	assert_true(m.rock_ng(3, 3))
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.sound.vibrations, [250, 250])

	assert_false(m.rock_ng(1, 0))
	assert_eq(m.sound.played, ["wrong", "wrong"])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 2
func test_cr_1193_check_2() -> void:
	var m = await _make_main()

	var p00 = _cell_pos(m, 0, 0)
	_touch_down(m, p00)
	_touch_up(m, p00)
	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.moves, 0)

	var p10 = _cell_pos(m, 1, 0)
	_touch_down(m, p10)
	_touch_up(m, p10)
	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])


## CHECK: 3
func test_cr_1193_check_3() -> void:
	var m = await _make_main()

	var p33 = _cell_pos(m, 3, 3)
	_touch_down(m, p33)
	_touch_up(m, p33)
	_touch_down(m, p33)
	_touch_up(m, p33)

	assert_eq(m.sound.played, ["wrong"])
	assert_eq(m.sound.vibrations, [250])
	assert_eq(m.session.board.state_at(3, 3), 0)
	assert_eq(m.session.moves, 0)


## CHECK: 4
func test_cr_1193_check_4() -> void:
	var m = await _make_main()

	var p00 = _cell_pos(m, 0, 0)
	_touch_down(m, p00)
	_touch_up(m, p00)
	assert_eq(m.sound.played, ["wrong"])

	var p01 = _cell_pos(m, 0, 1)
	var p10 = _cell_pos(m, 1, 0)

	_touch_down(m, p01)

	var drag1 := InputEventScreenDrag.new()
	drag1.index = 0
	drag1.position = p00
	m._input(drag1)

	var drag2 := InputEventScreenDrag.new()
	drag2.index = 0
	drag2.position = p10
	m._input(drag2)

	_touch_up(m, p10)

	assert_eq(m.sound.played, ["wrong", "mark"])
	assert_eq(m.sound.vibrations, [250, 15])
	assert_eq(m.session.board.state_at(0, 0), 0)
	assert_eq(m.session.board.state_at(0, 1), 1)
	assert_eq(m.session.board.state_at(1, 0), 1)
== 既存のテストの書き直し
== 終わり
