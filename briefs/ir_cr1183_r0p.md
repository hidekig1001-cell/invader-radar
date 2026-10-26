# クラウドへの依頼: InvaderRadar改修1183 の R0'（CR.md を読む）（2026-10-27 06:1x、Invader Radar29）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は b50af7e（v1.91-cr1182。1179〜1182 の振動が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きした draft/line の drafts/req_line_rules.txt（probe の名前だけ手元の req_cr1183_probe.gd に替えた）。手触りの 2 本目「そろったら line の音と光」の 3 本のうちの 1 本目（規則）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。
「そろった」の決め方（答えと比べるか）はユーザーの判断待ち（D-20261027-0545、推奨は下書きどおり「答えとは比べない」）。R0' は下書きどおりの決め方で読んでよい。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜5 の手順と期待値を落とさず写しているか。依頼の中心の条件（空が残ると []、宇宙人 1 つと × で埋めきると返る、宇宙人 2 つ・× だけの組は返らない、赤い宇宙人の組は返らない、並びは行→列→区域、小惑星とレーダーのマスは数えない）を確かめる項目が無ければ NG。
2. CR の変えること（core/rules.gd に static func filled_lines(board_state, level) -> Array を足す）が依頼と合っているか。依頼に無い箇条・余計な変更（scenes/ を変えるなど）・抜けが無いか。
3. 「変わる既存のテスト: なし」と「変わらない既存のテスト」が CR に写っているか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1183-r0p）のファイル results/cr1183_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。

## 依頼（req_cr1183.txt）

手触りの 2 本目「行・列・色（区域）がそろったら line の音と光」の 1 本目として、そろった組を返す規則の関数を足して（Invader Radar29 の依頼 10/27 03:1x。10/26 の解釈「宇宙人 1 つと × だけで埋まりきった瞬間」。音と光は、この関数を使う次の 2 本の CR で足す）。
「そろった組」は、行・列・区域のうち、小惑星とレーダー（数字）のマスを除いたマスが全部「宇宙人」か「×」で、宇宙人がちょうど 1 つあり、その宇宙人が赤くない（Rules.conflicts(board_state, level) の中に無い）組。空のマスが 1 つでも残る組、宇宙人が 0 個（× だけ）か 2 つ以上の組、宇宙人が赤い組は入れない。答え（正しい置き場所）と比べることはしない（くわしくは notes）。
返す値は組ごとの辞書の並び。辞書は {"kind": 種類, "index": 番号, "cells": マスの並び}。種類は "row"（行。番号は y）・"column"（列。番号は x）・"region"（区域。番号は区域の番号）。マスの並びは、小惑星とレーダーのマスを除き、y の小さい順、y が同じなら x の小さい順。組の並びは、行（y の小さい順）→ 列（x の小さい順）→ 区域（番号の小さい順）。例: 区域 0 と行 0 と列 0 が同時にそろっていれば [行 0, 列 0, 区域 0] の順。
- core/rules.gd に static func filled_lines(board_state, level) -> Array を足す。上の「そろった組」を、上の並びの辞書の並びで返す。board_state か level が null なら [] を返す。
- Rules.conflicts、Rules.dead_marks、ほかの規則の関数、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0) を順にしたあと（行 0 の (3, 0) が空）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 3, 0) をしたあと（行 0 が宇宙人 1 つと × 3 つで埋まった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 2, 0)、b.apply("mark", 1, 0)、b.apply("mark", 3, 0) と、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（行 0 は宇宙人 2 つと × 2 つ、行 3 は × だけ。どちらもそろった組ではない）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 2, 0) をしたあと（(2, 0) の宇宙人を × に替え、行 0 は宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 0, 2)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（(0, 0) と (0, 2) は同じ列なので 2 つとも赤い。行 0 は赤い宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は []。続けて b.apply("clear", 0, 2) をしたあと（(0, 0) が赤くなくなった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 がそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]。続けて b.apply("mark", 2, 0)、b.apply("mark", 3, 0)、b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（行 0 と列 0 もそろった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}, {"kind": "column", "index": 0, "cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]}, {"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]（行 → 列 → 区域の順）。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 0]], "radar": [[2, 0, 1]]}) をする（(3, 0) は小惑星、(2, 0) は数字 1 のレーダー。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 0, 0)、b.apply("place", 1, 0) を順にしたあと（行 0 は小惑星とレーダーを除くと (0, 0) の × と (1, 0) の宇宙人だけ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "手触りの 2 本目: 行・列・色がそろったら line の音と光"
  said_at: "2026-10-27 03:1x"
  decision: "D-20261026-0622"
  plan: "手触り（音・光・振動）"
  step: "そろった組を返す Rules.filled_lines を足す（手触り 2 本目の 1 つ目）"
title: "そろった行・列・区域を返す規則の関数"
probe: req_cr1183_probe.gd
decls:
  core/rules.gd:
  - "static func filled_lines(board_state, level) -> Array"
files:
  edit: [core/rules.gd]
  new: []
human:
  - "自動の項目だけ（画面は変わらない）。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0) を順にしたあと（行 0 の (3, 0) が空）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 3, 0) をしたあと（行 0 が宇宙人 1 つと × 3 つで埋まった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。'
  target: Rules.filled_lines(b, level)
  expect:
  - 'Rules.filled_lines(b, level)'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 2, 0)、b.apply("mark", 1, 0)、b.apply("mark", 3, 0) と、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（行 0 は宇宙人 2 つと × 2 つ、行 3 は × だけ。どちらもそろった組ではない）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 2, 0) をしたあと（(2, 0) の宇宙人を × に替え、行 0 は宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。'
  target: Rules.filled_lines(b, level)
  expect:
  - 'Rules.filled_lines(b, level)'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 0, 2)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（(0, 0) と (0, 2) は同じ列なので 2 つとも赤い。行 0 は赤い宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は []。続けて b.apply("clear", 0, 2) をしたあと（(0, 0) が赤くなくなった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。'
  target: Rules.filled_lines(b, level)
  expect:
  - 'Rules.filled_lines(b, level)'
- id: R4
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 がそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]。続けて b.apply("mark", 2, 0)、b.apply("mark", 3, 0)、b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（行 0 と列 0 もそろった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}, {"kind": "column", "index": 0, "cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]}, {"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]（行 → 列 → 区域の順）。'
  target: Rules.filled_lines(b, level)
  expect:
  - 'Rules.filled_lines(b, level)'
- id: R5
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 0]], "radar": [[2, 0, 1]]}) をする（(3, 0) は小惑星、(2, 0) は数字 1 のレーダー。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 0, 0)、b.apply("place", 1, 0) を順にしたあと（行 0 は小惑星とレーダーを除くと (0, 0) の × と (1, 0) の宇宙人だけ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]。'
  target: Rules.filled_lines(b, level)
  expect:
  - 'Rules.filled_lines(b, level)'
extra_items: 0
keep:
  files: [game/session.gd, scenes/main.gd, scenes/sound.gd, scenes/board_view.gd]
  other:
  - 'core/rules.gd の Rules.conflicts と Rules.dead_marks は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1173.gd::test_dead_marks_basic'
  - 'test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks'
```

## CR（CR-1183-1183v.local.md）

# CR-1183: そろった行・列・区域を返す規則の関数

## 変えること
- core/rules.gd に static func filled_lines(board_state, level) -> Array を足す。上の「そろった組」を、上の並びの辞書の並びで返す。board_state か level が null なら [] を返す。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/board_state.gd`、`core/deduce.gd`、`core/grid.gd`、`core/hint.gd`、`core/solver.gd`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/`、`test/`、`tools/`、`.autedev/`
- `core/rules.gd`: `conflicts`、`is_solved`、`radar_count`、`radar_conflicts`、`radar_satisfied`、`dead_marks`
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: core/rules.gd の Rules.conflicts と Rules.dead_marks は変えない（依頼の欄）

## 新しい宣言
- `res://core/rules.gd` に足す（既存のファイルに足す）
  - `static func filled_lines(board_state, level) -> Array`

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0) を順にしたあと（行 0 の (3, 0) が空）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 3, 0) をしたあと（行 0 が宇宙人 1 つと × 3 つで埋まった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 2, 0)、b.apply("mark", 1, 0)、b.apply("mark", 3, 0) と、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（行 0 は宇宙人 2 つと × 2 つ、行 3 は × だけ。どちらもそろった組ではない）の Rules.filled_lines(b, level) は []。続けて b.apply("mark", 2, 0) をしたあと（(2, 0) の宇宙人を × に替え、行 0 は宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("place", 0, 2)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（(0, 0) と (0, 2) は同じ列なので 2 つとも赤い。行 0 は赤い宇宙人 1 つと × 3 つ）の Rules.filled_lines(b, level) は []。続けて b.apply("clear", 0, 2) をしたあと（(0, 0) が赤くなくなった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 がそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]。続けて b.apply("mark", 2, 0)、b.apply("mark", 3, 0)、b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（行 0 と列 0 もそろった）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]}, {"kind": "column", "index": 0, "cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]}, {"kind": "region", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]}]（行 → 列 → 区域の順）。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 0]], "radar": [[2, 0, 1]]}) をする（(3, 0) は小惑星、(2, 0) は数字 1 のレーダー。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 0, 0)、b.apply("place", 1, 0) を順にしたあと（行 0 は小惑星とレーダーを除くと (0, 0) の × と (1, 0) の宇宙人だけ）の Rules.filled_lines(b, level) は [{"kind": "row", "index": 0, "cells": [Vector2i(0, 0), Vector2i(1, 0)]}]。
6. 既存のテストがすべて合格する。

## 人が確かめること
- 自動の項目だけ（画面は変わらない）。

## 変わらない既存のテスト
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ

## 対象の候補
- edit: `core/rules.gd`
