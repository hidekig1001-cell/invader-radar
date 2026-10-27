# クラウドへの依頼: InvaderRadar改修1190 の R0'（CR.md を読む）（1 回目、2026-10-27 19:1x、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、クラウドが下書きした draft/next-b の drafts/req_region_gaps.txt（probe の名前だけ手元の req_cr1190_probe.gd に替えた）。区域の番号が飛んでいる面（例 0・2・5・7）でも、Level.parse で番号を小さい順に 0, 1, 2, … に詰め直し、規則とヒントが全部の区域を見るようにする（今の面では何も変わらない）。CR は AuteDev の CR を作る役（機械の経路）が作った。
手元の当て試し（main 46fc619 の写し）では、直しを当てると 752 件すべて通り、直しなしでは probe の 3 件だけが落ちた。依頼の検査は error 0。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（詰め直すのは game/level.gd の parse の中だけ、番号の大小の並びは変えない、parse が false のときは何も変えない、region_at・region_count・to_dict と Rules・Deduce・Solver は変えない、to_dict は詰め直したあとの番号を書く）が、CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜3 の手順と期待値（region_count 4、region_at の 0〜3、to_dict の regions、右下の区域の dead_marks と filled_lines が [] にならない）を落とさず写しているか。依頼の中心の条件（番号が飛んでいる面でも大きい番号の区域を規則が見る）を確かめる項目が無ければ NG。
2. CR の変えること（game/level.gd の parse の 1 か所）が依頼と合っているか。依頼に無い箇条・余計な変更（Rules・Deduce のループを変えるなど）・抜けが無いか。
3. 「変わる既存のテスト: なし」と「変わらない既存のテスト」の 23 個が CR に写っているか。名前が main 46fc619 に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1190-r0p）のファイル results/cr1190_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1190.txt）

区域の番号が飛んでいる面（例: 0・2・5・7）でも、規則とヒントが全部の区域を見るようにして（引き継ぎの候補: 区域の番号が飛んでいる面では大きい番号の区域を見ない。今のデータは番号が 0 から続いていて困らない）。今は Rules.dead_marks・Rules.filled_lines と core/deduce.gd（ヒントの考え）の 2 か所が for r in range(level.region_count()) で区域を回すので、番号が飛んでいると、ある番号（例: 3）を空回りし、大きい番号（例: 7）を見ない。直す所を 1 つにするため、面を読む所（Level.parse）で区域の番号を小さい順に 0, 1, 2, … に詰め直す。番号が 0 から続いている面（今のすべての面）では何も変わらない。

- game/level.gd の func parse で、regions の数を Grid に入れたあと、出てきた番号を小さい順に並べ、いちばん小さい番号を 0、次を 1、… と詰め直した番号を Grid に入れ直す（例: 0・2・5・7 は 0・1・2・3 になる。番号の大小の並びは変えない。番号が 0 から続いている面では入れ直しても同じ）。parse が false を返すときは今と同じく何も変えない。
- Level の region_at・region_count・to_dict、Rules・Deduce・Solver の関数、ほかのファイルは変えない（to_dict は詰め直したあとの番号を書く）。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。level.parse の戻り値は true。そのあとの level.region_count() は 4、level.region_at(0, 0) は 0、level.region_at(2, 0) は 1、level.region_at(0, 2) は 2、level.region_at(3, 3) は 3、level.to_dict()["regions"] は [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（右下の区域（元の番号 7）が × だけになった）の Rules.dead_marks(b, level) は [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]（[] にしない）。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3) を順にしたあと（右下の区域が宇宙人 1 つと × 3 つでそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 3, "cells": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]}]（[] にしない）。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/unit/test_level.gd::test_parse_sample — 区域の番号は 0・1・2 と続いているので、region_at・region_count は今と同じ
- test/unit/test_level.gd::test_round_trip_through_json_text — 番号が続いている面は to_dict・JSON の行き来で同じ
- test/unit/test_level.gd::test_rejects_bad_shapes — 形が違うときは今と同じく false で何も変えない
- test/unit/test_level.gd::test_load_missing_file — ファイルの読み込みは変えない
- test/unit/test_level.gd::test_default_levels_are_square_with_one_region_per_row — 今の面の番号は 0 から続いている
- test/unit/test_level.gd::test_default_levels_have_distinct_ids_and_valid_regions — 同じ
- test/cr/test_cr_1040.gd::test_parse_level_with_radar — 番号は続いている
- test/cr/test_cr_1040.gd::test_write_radar_and_to_dict — 同じ
- test/cr/test_cr_1080b.gd::test_restore_dict_restores_level_board_moves_elapsed — 保存した面の番号は続いている
- test/cr/test_cr_1096.gd::test_save_dict_includes_moves_elapsed_level_rows — 同じ
- test/cr/test_cr_1096.gd::test_session_save_roundtrip_preserves_new_fields — 同じ
- test/cr/test_cr_1126.gd::test_prefetch_next_level — 作った面の番号は 0 から続いている
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない。番号は続いている
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_row_incomplete_then_complete — Rules.filled_lines は変えない。番号は続いている
- test/cr/test_cr_1183.gd::test_cr_1183_multiple_aliens_or_no_alien — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_conflicting_alien — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_region_and_ordering — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_1 — Deduce は変えない。番号は続いている
- test/cr/test_cr_1168.gd::test_analyze_level_2 — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_3_radar — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_3_eliminate — 同じ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: '（引き継ぎの候補）区域の番号が飛んでいる面では大きい番号の区域を見ない'
  said_at: "2026-10-27 18:2x"
  decision: "未定（ユーザーの判断の後に入れる）"
  plan: "不具合の芽を先に直す（B 組）"
  step: "区域の番号を面を読む所で 0 から詰め直す"
title: "区域の番号が飛んでいても全部の区域を見る"
probe: req_cr1190_probe.gd
decls: {}
files:
  edit: [game/level.gd]
  new: []
human:
  - "自動の項目だけ（今の面は番号が続いているので、画面は変わらない）。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。level.parse の戻り値は true。そのあとの level.region_count() は 4、level.region_at(0, 0) は 0、level.region_at(2, 0) は 1、level.region_at(0, 2) は 2、level.region_at(3, 3) は 3、level.to_dict()["regions"] は [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]。'
  target: level.parse
  expect:
  - 'level.region_at(3, 3)'
  - 'level.to_dict()["regions"]'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（右下の区域（元の番号 7）が × だけになった）の Rules.dead_marks(b, level) は [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]（[] にしない）。'
  target: Rules.dead_marks
  expect:
  - 'Rules.dead_marks(b, level)'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3) を順にしたあと（右下の区域が宇宙人 1 つと × 3 つでそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 3, "cells": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]}]（[] にしない）。'
  target: Rules.filled_lines
  expect:
  - 'Rules.filled_lines(b, level)'
extra_items: 0
keep:
  files: [core/rules.gd, core/deduce.gd, core/solver.gd, scenes/board_view.gd]
  other:
  - 'game/level.gd の region_at・region_count・to_dict は変えない'
changing_tests: []
unchanged_tests:
  - 'test/unit/test_level.gd::test_parse_sample'
  - 'test/unit/test_level.gd::test_round_trip_through_json_text'
  - 'test/unit/test_level.gd::test_rejects_bad_shapes'
  - 'test/unit/test_level.gd::test_load_missing_file'
  - 'test/unit/test_level.gd::test_default_levels_are_square_with_one_region_per_row'
  - 'test/unit/test_level.gd::test_default_levels_have_distinct_ids_and_valid_regions'
  - 'test/cr/test_cr_1040.gd::test_parse_level_with_radar'
  - 'test/cr/test_cr_1040.gd::test_write_radar_and_to_dict'
  - 'test/cr/test_cr_1080b.gd::test_restore_dict_restores_level_board_moves_elapsed'
  - 'test/cr/test_cr_1096.gd::test_save_dict_includes_moves_elapsed_level_rows'
  - 'test/cr/test_cr_1096.gd::test_session_save_roundtrip_preserves_new_fields'
  - 'test/cr/test_cr_1126.gd::test_prefetch_next_level'
  - 'test/cr/test_cr_1173.gd::test_dead_marks_basic'
  - 'test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_row_incomplete_then_complete'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_multiple_aliens_or_no_alien'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_conflicting_alien'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_region_and_ordering'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded'
  - 'test/cr/test_cr_1168.gd::test_analyze_level_1'
  - 'test/cr/test_cr_1168.gd::test_analyze_level_2'
  - 'test/cr/test_cr_1168.gd::test_analyze_level_3_radar'
  - 'test/cr/test_cr_1168.gd::test_analyze_level_3_eliminate'
```

## CR（CR-1190-1190v.local.md）

# CR-1190: 区域の番号が飛んでいても全部の区域を見る

## 変えること
- game/level.gd の func parse で、regions の数を Grid に入れたあと、出てきた番号を小さい順に並べ、いちばん小さい番号を 0、次を 1、… と詰め直した番号を Grid に入れ直す（例: 0・2・5・7 は 0・1・2・3 になる。番号の大小の並びは変えない。番号が 0 から続いている面では入れ直しても同じ）。parse が false を返すときは今と同じく何も変えない。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/cloud_payload.gd`、`game/level_maker.gd`、`game/level_pack.gd`、`game/level_prefetch.gd`、`game/licenses.gd`、`game/progress_store.gd`、`game/session.gd`、`game/session_save.gd`、`game/sound_settings.gd`、`game/tutorial.gd`、`game/tutorial_steps.gd`、`project.godot`、`scenes/`、`test/`、`tools/`、`.autedev/`
- `game/level.gd`: `id`、`asteroids`、`radar`、`to_json`、`parse_json`、`load_file`、`parse_radar`、`write_radar`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: core/deduce.gd は変えない（依頼の欄）。
- 依頼の欄: core/solver.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: game/level.gd の region_at・region_count・to_dict は変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。level.parse の戻り値は true。そのあとの level.region_count() は 4、level.region_at(0, 0) は 0、level.region_at(2, 0) は 1、level.region_at(0, 2) は 2、level.region_at(3, 3) は 3、level.to_dict()["regions"] は [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3)、b.apply("mark", 3, 3) を順にしたあと（右下の区域（元の番号 7）が × だけになった）の Rules.dead_marks(b, level) は [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]（[] にしない）。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 2, 2], [0, 0, 2, 2], [5, 5, 7, 7], [5, 5, 7, 7]]}) をする（区域の番号が 0・2・5・7 と飛んでいる面。左上・右上・左下・右下の 2×2 がそれぞれ 1 つの区域。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 2, 2)、b.apply("mark", 3, 2)、b.apply("mark", 2, 3) を順にしたあと（右下の区域が宇宙人 1 つと × 3 つでそろった）の Rules.filled_lines(b, level) は [{"kind": "region", "index": 3, "cells": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]}]（[] にしない）。
4. 既存のテストがすべて合格する。

## 人が確かめること
- 自動の項目だけ（今の面は番号が続いているので、画面は変わらない）。

## 変わらない既存のテスト
- test/unit/test_level.gd::test_parse_sample — 区域の番号は 0・1・2 と続いているので、region_at・region_count は今と同じ
- test/unit/test_level.gd::test_round_trip_through_json_text — 番号が続いている面は to_dict・JSON の行き来で同じ
- test/unit/test_level.gd::test_rejects_bad_shapes — 形が違うときは今と同じく false で何も変えない
- test/unit/test_level.gd::test_load_missing_file — ファイルの読み込みは変えない
- test/unit/test_level.gd::test_default_levels_are_square_with_one_region_per_row — 今の面の番号は 0 から続いている
- test/unit/test_level.gd::test_default_levels_have_distinct_ids_and_valid_regions — 同じ
- test/cr/test_cr_1040.gd::test_parse_level_with_radar — 番号は続いている
- test/cr/test_cr_1040.gd::test_write_radar_and_to_dict — 同じ
- test/cr/test_cr_1080b.gd::test_restore_dict_restores_level_board_moves_elapsed — 保存した面の番号は続いている
- test/cr/test_cr_1096.gd::test_save_dict_includes_moves_elapsed_level_rows — 同じ
- test/cr/test_cr_1096.gd::test_session_save_roundtrip_preserves_new_fields — 同じ
- test/cr/test_cr_1126.gd::test_prefetch_next_level — 作った面の番号は 0 から続いている
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない。番号は続いている
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_row_incomplete_then_complete — Rules.filled_lines は変えない。番号は続いている
- test/cr/test_cr_1183.gd::test_cr_1183_multiple_aliens_or_no_alien — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_conflicting_alien — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_region_and_ordering — 同じ
- test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_1 — Deduce は変えない。番号は続いている
- test/cr/test_cr_1168.gd::test_analyze_level_2 — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_3_radar — 同じ
- test/cr/test_cr_1168.gd::test_analyze_level_3_eliminate — 同じ

## 対象の候補
- edit: `game/level.gd`
