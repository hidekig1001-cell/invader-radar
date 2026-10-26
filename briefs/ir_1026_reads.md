# クラウドセッションへの依頼: IR の読み 3 つ（2026-10-26 21:5x、Invader Radar改修28）

リポジトリ hidekig1001-cell/invader-radar（private）。main は 8b632f5。アプリのコードは書き換えない。回答とファイルの文は日本語で。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、cr ブランチでは test/cr/ に入る。
- 振動の許可は、run が依頼の settings の行を export_presets.cfg に機械で当てる。

## 読み 1: CR-1176 の差分（branch cr/1176-safe-apply、main との差分）
依頼: export_presets.cfg の [preset.0.options] に permissions/vibrate=true を足す。permissions/internet=true、[preset.0] の name・platform、[preset.0.options] のほかの行、ほかのファイルは変えない。テスト test/cr/test_cr_1176.gd（ConfigFile で vibrate と internet が true）。
見ること: `git diff main...cr/1176-safe-apply` が依頼どおりか（export_presets.cfg の 1 行と新しいテストだけか、ほかの行・ファイルを変えていないか）。

## 読み 2: CR-1177 の差分（branch cr/1177-safe-apply、main との差分）
依頼: scenes/sound.gd に var vibrations: Array = [] と func vibrate(ms: int) -> void（vibrations に ms を足してから Input.vibrate_handheld(ms)）。scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "place" なら sound.vibrate(30)。効果音の選び方（Sound.sfx_for）と鳴らし方、駒の弾み、ほかのファイルは変えない。テストは宇宙人を置くと vibrations が [30]、× では増えない。
見ること: 差分が依頼どおりか。place 以外（mark・clear・level_clear・wrong・hint）で振動しないか。チュートリアル・既存の効果音の鳴り方を変えていないか。余計な変更が無いか。

## 読み 3: CR-1178 の R3'（新しいテストと既存のテストの書き直しを読む）
依頼と CR は branch review/cr1178-r0p-2 の briefs/ir_cr1178b_r0p.md にある（確かめる項目 1 の最後の期待値は「m.bubble.text は m.help_text() の値と同じ」）。下の材料（run が作った新しいテストと、既存のテストの main との差分）を読み比べ、各 CHECK が依頼の手順と期待値をそのまま写しているか、test_cr_1172 の 2 関数の書き直しが依頼どおり（tick_size_up の行を足すだけで表明は変えない）か、今の main でこのテストが落ちるかを見る。

### 材料
== tests/test_cr_1178.gd
extends GutTest

const Level = preload("res://game/level.gd")
const SessionScript = preload("res://game/session.gd")
const MS = preload("res://scenes/main.tscn")

func test_cr_1178_size_up_wait_and_age() -> void:
	## CHECK: 1
	var l1 = Level.new()
	l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})
	var l2 = Level.new()
	l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var l3 = Level.new()
	l3.parse({"id": 3, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})
	var s = SessionScript.new([l1, l2, l3])
	var m = MS.instantiate()
	m.language = "ja"
	m.session = s
	add_child_autofree(m)
	await wait_frames(2)
	s.solve_now()
	var down = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(540, 300)
	m._input(down)
	assert_eq(s.level_index, 1)
	assert_false(m.bubble.tile_mode)
	assert_eq(m.size_up_wait, 0.6)
	m.tick_size_up(0.7)
	assert_true(m.bubble.tile_mode)
	assert_eq(m.bubble.text, "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる")
	m._input(down)
	assert_true(m.bubble.tile_mode)
	m.tick_size_up(1.0)
	m._input(down)
	assert_false(m.bubble.tile_mode)
	assert_eq(m.bubble.text, m.help_text())
== 既存のテストの書き直し
-- test__cr__test_cr_1172.gd
24a25,27
> 	assert_eq(m.size_up_wait, 0.6)
> 	assert_false(m.bubble.tile_mode)
> 	m.tick_size_up(0.7)
34a38,41
> 	assert_true(m.bubble.tile_mode)
> 	m.tick_size_up(1.0)
> 	m._input(down)
> 	await wait_frames(1)
57a65,67
> 	assert_eq(m.size_up_wait, 0.6)
> 	assert_false(m.bubble.tile_mode)
> 	m.tick_size_up(0.7)
== 終わり

## 終わりの条件（必ず守る）
- 結果を、この branch（review/ir-1026-reads）のファイル results/ir_1026_reads.md に書いて commit・push する。読みごとに 1 行目を「差分 OK」「差分 NG: <理由>」「R3' OK」「R3' NG: <理由>」の形で書き、続けて見立てを短く。main・ほかの branch には触らない。
- 最後の返答にも、3 つの 1 行目を書く。
