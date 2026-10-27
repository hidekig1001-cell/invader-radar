# クラウドへの依頼: InvaderRadar改修1192 の R3'（テストを読む）（1 回目、2026-10-27 19:4x、Invader Radar31）

依頼と CR は branch review/cr1192-r0p の briefs/ir_cr1192_r0p.md（R0' は OK、results/cr1192_r0p.md）。main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。
これまでの読みで分かった決まり: 既存のテストに依頼に無い表明を足していたら NG（1182）。新しいテストの途中の段の表明は、依頼の流れで必ず成り立つ値なら OK。期待値を「数と各キー」・「数と各要素」に分けた形は NG（1183・1190）。まだ無い関数をファイルの頭の preload の const から呼ぶと、ファイルごと Parse Error になり GUT が飛ばして「全部通過」に見える（1188）。関数の中の load で呼んでいるかも見る。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜3 の手順と期待値（レーダーの岩・小惑星に宇宙人を置いた盤の Rules.dead_marks の値まるごと、岩でないマスの宇宙人で [] になる、区域と列の値まるごと）をそのまま写しているか。足りない手順・違う期待値・依頼に無い手や表明が無いか。
2. 期待値が今の main（46fc619）でも成り立ってしまわないか（どの関数も今の main で落ちるか。項目 2 の後半の [] は今の main でも成り立つが、前半が落ちれば関数は落ちる）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1192-r3p のファイル results/cr1192_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-1934-CR-1192
== tests/test_cr_1192.gd
extends GutTest

func test_cr_1192_radar_cell_skipped_in_row() -> void:
	## CHECK: 1
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"radar": [[0, 0, 1]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_cr_1192_asteroid_skipped_in_row() -> void:
	## CHECK: 2
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"asteroids": [[3, 3]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 3, 3)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)])
	
	b.apply("place", 1, 3)
	result = Rules.dead_marks(b, level)
	assert_eq(result, [])


func test_cr_1192_radar_cell_skipped_in_region_and_col() -> void:
	## CHECK: 3
	var Level = load("res://game/level.gd")
	var Rules = load("res://core/rules.gd")
	var BS = load("res://core/board_state.gd")
	
	var level = Level.new()
	level.parse({
		"width": 4, 
		"height": 4, 
		"target": 4, 
		"regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], 
		"radar": [[0, 0, 1]]
	})
	
	var b = BS.new(4, 4)
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	
	var result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	
	result = Rules.dead_marks(b, level)
	assert_eq(result, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)])
== 既存のテストの書き直し
== 終わり
