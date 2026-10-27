# クラウドへの依頼: InvaderRadar改修1185 の R0'（CR.md を読む）（1 回目、2026-10-27 14:3x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 61433f2（v1.93-cr1184。1183 の Rules.filled_lines と 1184 の line の音が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きした draft/line の drafts/req_line_flash.txt（probe の名前だけ手元の req_cr1185_probe.gd に替えた）。手触りの 2 本目「そろったら line の音と光」の 3 本のうちの 3 本目（光）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。
ユーザーの判断 D-20261027-0545＝A（提案どおり）: 答えとは比べない。line の手では振動しない。
手元の当て試し（main 5f52a46 の上で rules は main のまま・sound と flash を当てた）では、probe は全部通り、落ちたのは 1184 で書き換える test_cr_1179_main_dead_with_alien の 1 件だけだった（1184 が main に入ったので、61433f2 の上では落ちないはず）。今の main では probe の 4 件が落ちた。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。光らせるのは line を鳴らした手だけ（dead・level_clear の手、チュートリアル、最初の _refresh では光らない）・同じマスは 1 回だけ描く・flashes に組ごとに記録する、の決まりが、CR の変えることか確かめる項目に写っているかを見る（変えることの main.gd の箇条「sfx_name が "line" なら board_view.flash_lines(new_lines)」で line の手だけに限られる）。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜4 の手順と期待値を落とさず写しているか（flashes・flash_cells の値まるごと、flash_alpha の 0.5・0.25・0.0 と誤差 0.001、組の並び 行 0 → 区域 0、dead の手で [] など）。依頼の中心の条件（そろった手で光る・宇宙人を置いた手と × の手では光らない・2 つの組が同時なら両方で同じマスは 1 回・dead の手では光らない・明るさが 0.3 秒で 0.5 から 0 に下がる）を確かめる項目が無ければ NG。
2. CR の変えること（board_view.gd の LINE_FLASH_TIME・flashes・flash_cells・flash_start、flash_lines・flash_alpha、_draw と _process、main.gd の flash_lines の呼び出し）が依頼と合っているか。依頼に無い箇条・余計な変更（宇宙人の弾み・マスと × の描き方・効果音と振動を変えるなど）・抜けが無いか。
3. 「変わる既存のテスト: なし」と「変わらない既存のテスト」の 4 つが CR に写っているか。4 つのテストの名前が main 61433f2 に実際にあるか（手元では確かめられなかった）。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1185-r0p）のファイル results/cr1185_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く（決まりは箇条の中に書く。「上の」で頭の段落を指さない）。main・ほかの branch には触らない。
## 依頼（req_cr1185.txt）

行・列・色（区域）がそろった瞬間に、そろった組のマスを短く光らせて（手触りの 2 本目の 3 つ目。Invader Radar29 の依頼 10/27 03:1x。2 つ目の CR で line を鳴らす手と同じ手で光らせる）。
光は、そろった組のマスのタイルの上に白い四角（角を丸めたタイルの形）を描き足すもので、明るさ（白の不透明度）は光り始めに 0.5、0.3 秒かけて 0 まで直線で下げて消す。宇宙人を置いたときの弾み（CR-1169）と同じく、board_view の pop_clock で時間をはかる。
光らせるのは line を鳴らした手だけ（新しくそろった組のマス）。dead・level_clear の手、チュートリアルの間、最初の _refresh では光らせない。1 回の手で 2 つの組がそろったら、2 つの組のマスを同時に光らせる（同じマスは 1 回だけ描く）。テストから読めるように、光らせた組のマスの並びを board_view の flashes に順に記録する。
- scenes/board_view.gd に const LINE_FLASH_TIME := 0.3、var flashes: Array = []、var flash_cells: Array = []、var flash_start: float = -1.0 を足す。
- scenes/board_view.gd に func flash_lines(lines: Array) -> void を足す。flash_cells を [] にしてから、lines の組ごとに flashes に組の "cells" を足し、flash_cells に組のマスを（まだ無いものだけ）足す。flash_start = pop_clock とし、queue_redraw() を呼ぶ。func flash_alpha(now: float) -> float を足す。flash_start が 0 未満なら 0.0、t = (now - flash_start) / LINE_FLASH_TIME が 0 未満か 1 以上なら 0.0、ほかは 0.5 * (1.0 - t) を返す。
- scenes/board_view.gd の func _draw で、マスの中身を描いたあと（「5. Draw Highlight/Darkening」の前）に、flash_alpha(pop_clock) が 0 より大きければ flash_cells のマスごとに tile_rect のタイルの形で Color(1, 1, 1, その値) を描く。func _process で、flash_start が 0 以上で pop_clock - flash_start が LINE_FLASH_TIME + delta より小さいあいだ queue_redraw() を呼ぶ。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "line" なら board_view.flash_lines(new_lines) を呼ぶ。
- 宇宙人の弾み、マス・× の描き方、効果音と振動、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var BV = load("res://scenes/board_view.gd") とし、var bv = BV.new() を add_child_autofree(bv) する。bv.flashes は [] で、bv.flash_alpha(0.0) は 0.0（まだ光っていない）。bv.flash_lines([{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]) をしたあとの bv.flashes は [[Vector2i(0, 0), Vector2i(1, 0)]]、bv.flash_cells は [Vector2i(0, 0), Vector2i(1, 0)]。bv.flash_alpha(bv.flash_start) は 0.5（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.15) は 0.25（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.3) は 0.0。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0) を順にしたあと（宇宙人を置いた手と × を付けた手では光らない）の m.board_view.flashes は []。続けて m.session.tap(3, 0) をしたあと（行 0 がそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 2, 0)、m.session.board.apply("mark", 3, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく。add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(1, 0) をしたあと（1 回の手で行 0 と区域 0 が同時にそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]（行 0 → 区域 0 の順）、m.board_view.flash_cells は [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1)]（同じマスは 1 回だけ）。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 1)、m.session.tap(3, 2)、m.session.tap(3, 3) を順にし、続けて m.session.tap(3, 0) をしたあと（行 0 がそろい、同じ手で列 3 が × だけで埋まった。この手は dead の手なので光らない）の m.board_view.flashes は []。続けて m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が新しくそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1169.gd::test_piece_pop_scale_and_scaled_rect — 宇宙人の弾みは変えない
- test/cr/test_cr_1169.gd::test_piece_pop_start_updated_on_place_and_clear — 同じ
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — _refresh を呼ぶが、見ているのは吹き出しとヒントだけ
- test/cr/test_cr_1022.gd::test_tile_rect_values — タイルの形は変えない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "手触りの 2 本目: 行・列・色がそろったら line の音と光"
  said_at: "2026-10-27 03:1x"
  decision: "D-20261026-0622"
  plan: "手触り（音・光・振動）"
  step: "そろった組のマスを短く光らせる（手触り 2 本目の 3 つ目）"
title: "行・列・区域がそろった瞬間に光らせる"
probe: req_cr1185_probe.gd
decls:
  scenes/board_view.gd:
  - "const LINE_FLASH_TIME := 0.3"
  - "var flashes: Array = []"
  - "var flash_cells: Array = []"
  - "var flash_start: float = -1.0"
  - "func flash_lines(lines: Array) -> void"
  - "func flash_alpha(now: float) -> float"
files:
  edit: [scenes/board_view.gd, scenes/main.gd]
  new: []
human:
  - "Pixel で行・列・区域のどれかがそろった瞬間に、そのマスが一瞬白っぽく光ってすぐ戻ることを見る。宇宙人を置いたときの弾みと同時に出ても見づらくないかを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var BV = load("res://scenes/board_view.gd") とし、var bv = BV.new() を add_child_autofree(bv) する。bv.flashes は [] で、bv.flash_alpha(0.0) は 0.0（まだ光っていない）。bv.flash_lines([{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]) をしたあとの bv.flashes は [[Vector2i(0, 0), Vector2i(1, 0)]]、bv.flash_cells は [Vector2i(0, 0), Vector2i(1, 0)]。bv.flash_alpha(bv.flash_start) は 0.5（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.15) は 0.25（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.3) は 0.0。'
  target: bv.flash_lines
  expect:
  - 'bv.flashes'
  - 'bv.flash_alpha'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0) を順にしたあと（宇宙人を置いた手と × を付けた手では光らない）の m.board_view.flashes は []。続けて m.session.tap(3, 0) をしたあと（行 0 がそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]]。'
  target: m.session.tap
  expect:
  - 'm.board_view.flashes'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 2, 0)、m.session.board.apply("mark", 3, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく。add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(1, 0) をしたあと（1 回の手で行 0 と区域 0 が同時にそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]（行 0 → 区域 0 の順）、m.board_view.flash_cells は [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1)]（同じマスは 1 回だけ）。'
  target: m.session.tap
  expect:
  - 'm.board_view.flashes'
  - 'm.board_view.flash_cells'
- id: R4
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 1)、m.session.tap(3, 2)、m.session.tap(3, 3) を順にし、続けて m.session.tap(3, 0) をしたあと（行 0 がそろい、同じ手で列 3 が × だけで埋まった。この手は dead の手なので光らない）の m.board_view.flashes は []。続けて m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が新しくそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]。'
  target: m.session.tap
  expect:
  - 'm.board_view.flashes'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, scenes/sound.gd]
  other:
  - 'scenes/board_view.gd の宇宙人の弾み（piece_pop_scale）とマス・× の描き方は変えない'
  - 'scenes/main.gd の効果音の選び方（line に替える決まり）は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1169.gd::test_piece_pop_scale_and_scaled_rect'
  - 'test/cr/test_cr_1169.gd::test_piece_pop_start_updated_on_place_and_clear'
  - 'test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change'
  - 'test/cr/test_cr_1022.gd::test_tile_rect_values'
```

## CR（CR-1185-1185v.local.md）

# CR-1185: 行・列・区域がそろった瞬間に光らせる

## 変えること
- scenes/board_view.gd に const LINE_FLASH_TIME := 0.3、var flashes: Array = []、var flash_cells: Array = []、var flash_start: float = -1.0 を足す。
- scenes/board_view.gd に func flash_lines(lines: Array) -> void を足す。flash_cells を [] にしてから、lines の組ごとに flashes に組の "cells" を足し、flash_cells に組のマスを（まだ無いものだけ）足す。flash_start = pop_clock とし、queue_redraw() を呼ぶ。func flash_alpha(now: float) -> float を足す。flash_start が 0 未満なら 0.0、t = (now - flash_start) / LINE_FLASH_TIME が 0 未満か 1 以上なら 0.0、ほかは 0.5 * (1.0 - t) を返す。
- scenes/board_view.gd の func _draw で、マスの中身を描いたあと（「5. Draw Highlight/Darkening」の前）に、flash_alpha(pop_clock) が 0 より大きければ flash_cells のマスごとに tile_rect のタイルの形で Color(1, 1, 1, その値) を描く。func _process で、flash_start が 0 以上で pop_clock - flash_start が LINE_FLASH_TIME + delta より小さいあいだ queue_redraw() を呼ぶ。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "line" なら board_view.flash_lines(new_lines) を呼ぶ。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/board_view.gd`: `Rules`、`AREA`、`REGION_COLORS`、`MARK_COLOR`、`PIECE_FILL`、`CONFLICT_FILL`、`GRID_LINE`、`MARK_ON_NUMBER_COLOR`、`PIECE_NUMBER_COLOR`、`PIECE_TEXTURES`、`ROCK_TEXTURE`、`REGION_PIECE_COLORS`、`ALIEN_ROWS`、`ROCK_ROWS`、`ROCK_COLOR`、`ROCK_SHADOW_COLOR`、`hint_cell`、`highlight_cells`、`PIECE_POSE_TEXTURES`、`piece_poses`、`pose_rng`、`PIECE_POP_TIME`、`piece_pop_start`、`grid_size`、`geometry`、`cell_rect`、`board_rect`、`region_color`、`piece_fill`、`alien_rows`、`rock_rows`、`is_rock`、`alien_pixel_rect`、`corner_radius`、`board_bg_rect`、`mark_color`、`mark_thickness`、`round_rect_points`、`radar_font_size`、`radar_label_center`、`radar_text_color`、`has_piece_at`、`has_radar`、`mark_color_at`、`radar_outline_color`、`radar_outline_size`、`piece_color_name`、`piece_texture`、`rock_texture`、`piece_image_rect`、`piece_pose`、`forget_empty_poses`、`piece_pop_scale`、`scaled_rect`、`rock_image_at`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`last_dead`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd の宇宙人の弾み（piece_pop_scale）とマス・× の描き方は変えない（依頼の欄）
- 依頼の欄: scenes/main.gd の効果音の選び方（line に替える決まり）は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/board_view.gd` に足す（既存のファイルに足す）
  - `const LINE_FLASH_TIME := 0.3`
  - `var flashes: Array = []`
  - `var flash_cells: Array = []`
  - `var flash_start: float = -1.0`
  - `func flash_lines(lines: Array) -> void`
  - `func flash_alpha(now: float) -> float`

## 自動で確かめること
1. テストの関数の中で var BV = load("res://scenes/board_view.gd") とし、var bv = BV.new() を add_child_autofree(bv) する。bv.flashes は [] で、bv.flash_alpha(0.0) は 0.0（まだ光っていない）。bv.flash_lines([{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]) をしたあとの bv.flashes は [[Vector2i(0, 0), Vector2i(1, 0)]]、bv.flash_cells は [Vector2i(0, 0), Vector2i(1, 0)]。bv.flash_alpha(bv.flash_start) は 0.5（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.15) は 0.25（誤差 0.001 まで）、bv.flash_alpha(bv.flash_start + 0.3) は 0.0。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0) を順にしたあと（宇宙人を置いた手と × を付けた手では光らない）の m.board_view.flashes は []。続けて m.session.tap(3, 0) をしたあと（行 0 がそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 2, 0)、m.session.board.apply("mark", 3, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく。add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(1, 0) をしたあと（1 回の手で行 0 と区域 0 が同時にそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]（行 0 → 区域 0 の順）、m.board_view.flash_cells は [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1)]（同じマスは 1 回だけ）。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 1)、m.session.tap(3, 2)、m.session.tap(3, 3) を順にし、続けて m.session.tap(3, 0) をしたあと（行 0 がそろい、同じ手で列 3 が × だけで埋まった。この手は dead の手なので光らない）の m.board_view.flashes は []。続けて m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が新しくそろった）の m.board_view.flashes は [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]]。
5. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で行・列・区域のどれかがそろった瞬間に、そのマスが一瞬白っぽく光ってすぐ戻ることを見る。宇宙人を置いたときの弾みと同時に出ても見づらくないかを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1169.gd::test_piece_pop_scale_and_scaled_rect — 宇宙人の弾みは変えない
- test/cr/test_cr_1169.gd::test_piece_pop_start_updated_on_place_and_clear — 同じ
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — _refresh を呼ぶが、見ているのは吹き出しとヒントだけ
- test/cr/test_cr_1022.gd::test_tile_rect_values — タイルの形は変えない

## 対象の候補
- edit: `scenes/board_view.gd`、`scenes/main.gd`
