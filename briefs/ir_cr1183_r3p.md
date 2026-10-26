# クラウドへの依頼: InvaderRadar改修1183 の R3'（テストを読む）（2026-10-27 06:2x、Invader Radar29）

依頼と CR は branch review/cr1183-r0p-2 の briefs/ir_cr1183_r0p2.md（R0' は 2 回目で OK、results/cr1183_r0p_2.md）。main は b50af7e（v1.91-cr1182）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
AuteDev の決まり: 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。置き場所は NG の理由にしない。既存のテストの書き直しは tests/existing/ に置かれ、ファイル名の __ は / の代わり。CR の「変えないこと」の test/ は機械の決まった欄で、NG の理由にしない。

見ること:
1. 各 CHECK の関数が、依頼の確かめる項目 1〜5 の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか（辞書の並び・cells の並び・kind の名前まで）。
2. 期待値が今の main（b50af7e）でも成り立ってしまわないか（どの関数も今の main で落ちるか）。
3. 既存のテストの書き直しが無いこと（依頼は「変わる既存のテスト: なし」）。

終わりの条件: 結果を branch review/cr1183-r3p のファイル results/cr1183_r3p.md に書いて commit・push。1 行目は「R3' OK」か「R3' NG: <理由>」。NG なら、どの関数のどの表明かを `関数名` で書く（差し戻しに使う）。main・ほかの branch には触らない。

## 材料（run の新しいテストと、既存のテストの書き直しの main との差分）
run: 20261027-0616-CR-1183
== tests/test_cr_1183.gd
extends GutTest

const Level = preload("res://game/level.gd")
const Rules = preload("res://core/rules.gd")
const BS = preload("res://core/board_state.gd")


func _make_level() -> Level:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		]
	})
	return level


## CHECK: 1
func test_cr_1183_row_incomplete_then_complete() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	# (3, 0) is empty, so row 0 is not filled
	var result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 0)
	
	b.apply("mark", 3, 0)
	# Row 0 is now filled with 1 alien and 3 marks
	result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 1)
	if result.size() > 0:
		var line = result[0]
		assert_eq(line["kind"], "row")
		assert_eq(line["index"], 0)
		assert_eq(line["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


## CHECK: 2
func test_cr_1183_multiple_aliens_or_no_alien() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Row 0 has 2 aliens
	b.apply("place", 0, 0)
	b.apply("place", 2, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 3, 0)
	
	# Row 3 has only marks (0 aliens)
	b.apply("mark", 0, 3)
	b.apply("mark", 1, 3)
	b.apply("mark", 2, 3)
	b.apply("mark", 3, 3)
	
	var result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 0)
	
	# Change (2, 0) from alien to mark. Now Row 0 has 1 alien and 3 marks.
	b.apply("clear", 2, 0)
	b.apply("mark", 2, 0)
	
	result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 1)
	if result.size() > 0:
		var line = result[0]
		assert_eq(line["kind"], "row")
		assert_eq(line["index"], 0)
		assert_eq(line["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


## CHECK: 3
func test_cr_1183_conflicting_alien() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Place aliens at (0, 0) and (0, 2). They are in the same column, so they conflict.
	b.apply("place", 0, 0)
	b.apply("place", 0, 2)
	
	# Fill row 0 with marks except for the alien at (0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	# Row 0 has an alien that is in conflict, so it should not be returned.
	var result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 0)
	
	# Clear the conflicting alien at (0, 2). Now (0, 0) is no longer in conflict with another alien.
	b.apply("clear", 0, 2)
	
	result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 1)
	if result.size() > 0:
		var line = result[0]
		assert_eq(line["kind"], "row")
		assert_eq(line["index"], 0)
		assert_eq(line["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


## CHECK: 4
func test_cr_1183_region_and_ordering() -> void:
	var level = _make_level()
	var b = BS.new(4, 4)
	
	# Fill region 0: (0,0) alien, others marks
	b.apply("place", 0, 0)
	b.apply("mark", 1, 0)
	b.apply("mark", 0, 1)
	b.apply("mark", 1, 1)
	
	var result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 1)
	if result.size() > 0:
		var line = result[0]
		assert_eq(line["kind"], "region")
		assert_eq(line["index"], 0)
		assert_eq(line["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
		
	# Now fill row 0 and column 0 completely.
	# Row 0: (0,0) is alien, (1,0) mark, need (2,0) and (3,0) marks.
	b.apply("mark", 2, 0)
	b.apply("mark", 3, 0)
	
	# Column 0: (0,0) is alien, (0,1) mark, need (0,2) and (0,3) marks.
	b.apply("mark", 0, 2)
	b.apply("mark", 0, 3)
	
	result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 3)
	if result.size() == 3:
		# Order: Row (y=0), Column (x=0), Region (id=0)
		var line0 = result[0]
		assert_eq(line0["kind"], "row")
		assert_eq(line0["index"], 0)
		assert_eq(line0["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])
		
		var line1 = result[1]
		assert_eq(line1["kind"], "column")
		assert_eq(line1["index"], 0)
		assert_eq(line1["cells"], [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)])
		
		var line2 = result[2]
		assert_eq(line2["kind"], "region")
		assert_eq(line2["index"], 0)
		assert_eq(line2["cells"], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])


## CHECK: 5
func test_cr_1183_asteroids_and_radar_excluded() -> void:
	var level = Level.new()
	level.parse({
		"width": 4,
		"height": 4,
		"target": 4,
		"regions": [
			[0, 0, 1, 1],
			[0, 0, 1, 1],
			[2, 2, 3, 3],
			[2, 2, 3, 3]
		],
		"asteroids": [[3, 0]],
		"radar": [[2, 0, 1]]
	})
	var b = BS.new(4, 4)
	
	# Row 0 cells: (0,0), (1,0), (2,0)[Radar], (3,0)[Asteroid]
	# We place alien at (1,0) and mark at (0,0).
	# (2,0) is radar, (3,0) is asteroid. They are excluded from the "filled" check logic for cells, 
	# but the line itself is considered if the non-excluded cells are filled.
	b.apply("mark", 0, 0)
	b.apply("place", 1, 0)
	
	var result = Rules.filled_lines(b, level)
	assert_eq(result.size(), 1)
	if result.size() > 0:
		var line = result[0]
		assert_eq(line["kind"], "row")
		assert_eq(line["index"], 0)
		# Cells should exclude asteroid (3,0) and radar (2,0).
		# Remaining cells in row 0 are (0,0) and (1,0).
		assert_eq(line["cells"], [Vector2i(0, 0), Vector2i(1, 0)])
== 既存のテストの書き直し
== 終わり
