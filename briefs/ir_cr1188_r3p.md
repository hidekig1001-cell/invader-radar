# クラウドへの依頼: InvaderRadar改修1188 の R3'（テストを読む）（1 回目、2026-10-27 17:5x、Invader Radar30）

依頼と CR は branch review/cr1188-r0p の briefs/ir_cr1188_r0p.md（R0' は OK、results/cr1188_r0p.md）。main は 9193cdf（v1.96-cr1186）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」に分けた形は NG（1183）。小数の期待値に誤差を付けるのは、依頼が付けていれば必ず、付けていなくても丸めで正しい実装が落ちうる所なら OK（1185）。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜5 の手順と期待値（色・縁の太さ・字の大きさ・pivot_offset・pop_age・弾みの大きさと誤差・size_up_mode・tile_mode・stylebox・音と振動の記録）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（9193cdf）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1188-r3p のファイル results/cr1188_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1742-CR-1188
== tests/test_cr_1188.gd
extends GutTest

const MessageBubbleScript = preload("res://scenes/message_bubble.gd")
const LevelScript = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MainScene = preload("res://scenes/main.tscn")

## CHECK: 1
func test_cr_1188_show_size_up_state() -> void:
	var b = MessageBubbleScript.new()
	add_child_autofree(b)
	var text = "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"
	b.show_size_up(text, Vector2(540, 980))
	
	assert_true(b.size_up_mode)
	assert_true(b.tile_mode)
	assert_eq(b.text, text)
	
	var sb = b.get_theme_stylebox("normal")
	assert_eq(sb.bg_color, Color8(255, 215, 64))
	assert_eq(sb.border_color, Color8(230, 110, 20))
	assert_eq(sb.border_width_top, 8)
	
	var expected_font_size = b.fit_font_size(text, MessageBubbleScript.TILE_SIZE, 52, 36)
	assert_eq(b.get_theme_font_size("font_size"), expected_font_size)
	
	assert_true(b.pivot_offset.is_equal_approx(Vector2(450, 80)))
	assert_almost_eq(b.pop_age, 0.0, 0.001)

## CHECK: 2
func test_cr_1188_size_up_pop_scale() -> void:
	assert_almost_eq(MessageBubbleScript.size_up_pop_scale(0.15), 1.25, 0.001)
	assert_almost_eq(MessageBubbleScript.size_up_pop_scale(0.075), 1.1768, 0.001)
	assert_almost_eq(MessageBubbleScript.size_up_pop_scale(0.0), 1.0, 0.001)
	assert_almost_eq(MessageBubbleScript.size_up_pop_scale(0.3), 1.0, 0.001)
	assert_almost_eq(MessageBubbleScript.size_up_pop_scale(-1.0), 1.0, 0.001)

## CHECK: 3
func test_cr_1188_step_pop() -> void:
	var b = MessageBubbleScript.new()
	add_child_autofree(b)
	var text = "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"
	b.show_size_up(text, Vector2(540, 980))
	
	b.step_pop(0.15)
	assert_almost_eq(b.pop_age, 0.15, 0.001)
	assert_true(b.scale.is_equal_approx(Vector2(1.25, 1.25)))
	
	b.step_pop(0.2)
	assert_almost_eq(b.pop_age, -1.0, 0.001)
	assert_true(b.scale.is_equal_approx(Vector2(1, 1)))

## CHECK: 4
func test_cr_1188_clear_text_restores_size_up() -> void:
	var b = MessageBubbleScript.new()
	add_child_autofree(b)
	var text = "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"
	b.show_size_up(text, Vector2(540, 980))
	
	assert_true(b.size_up_mode)
	assert_eq(b.get_theme_stylebox("normal").bg_color, Color8(255, 215, 64))
	
	b.step_pop(0.1)
	assert_true(b.scale.is_equal_approx(Vector2(1.2165, 1.2165)))
	
	b.clear_text()
	assert_false(b.size_up_mode)
	assert_false(b.tile_mode)
	assert_almost_eq(b.pop_age, -1.0, 0.001)
	assert_true(b.scale.is_equal_approx(Vector2(1, 1)))
	assert_eq(b.get_theme_stylebox("normal"), b.normal_box)
	assert_eq(b.get_theme_font_size("font_size"), MessageBubbleScript.FONT_SIZE)

## CHECK: 5
func test_cr_1188_main_integration() -> void:
	var l1 = LevelScript.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = LevelScript.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = LevelScript.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	
	var m = MainScene.instantiate()
	m.session = SessionScript.new([l1, l2, l3])
	add_child_autofree(m)
	await wait_frames(2)
	
	m.session.solve_now()
	assert_true(m.bubble.tile_mode)
	assert_false(m.bubble.size_up_mode)
	
	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	
	assert_eq(m.session.level_index, 1)
	assert_eq(m.sound.played.count("line"), 0)
	
	m.tick_size_up(0.7)
	assert_true(m.bubble.size_up_mode)
	assert_eq(m.bubble.text, m.size_up_tile_text())
	assert_eq(m.bubble.get_theme_stylebox("normal").bg_color, Color8(255, 215, 64))
	assert_eq(m.sound.played.count("line"), 1)
	assert_eq(m.sound.vibrations[-1], 60)
	assert_almost_eq(m.sound.vibration_amplitudes[-1], 0.6, 0.001)
== 既存のテストの書き直し
== 終わり
