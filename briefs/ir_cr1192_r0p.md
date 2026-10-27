# クラウドへの依頼: InvaderRadar改修1192 の R0'（CR.md を読む）（1 回目、2026-10-27 19:1x、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなたが下書きした draft/next-a の drafts/req_dead_marks_order.txt。手元で変えたのは 2 つ: probe の名前を req_cr1192_probe.gd に、title を「× だけの組の判定で岩のマスを先に飛ばす」に（元の題は 36 字で、依頼の検査の「title は 30 字まで」に当たった。次から下書きの title は 30 字までにしてほしい）。Rules.dead_marks の 3 つのループで、岩（小惑星・レーダー）のマスの continue を状態の判定より前に移す。CR は AuteDev の CR を作る役（機械の経路）が作った。
手元の当て試し（main 46fc619 の写し）では、直しを当てると 752 件すべて通り、直しなしでは probe の 3 件だけが落ちた。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（状態の見方・返す並び・filled_lines・conflicts は変えない、岩のマスの宇宙人も × も数えない）が CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜3 の手順と期待値を落とさず写しているか。依頼の中心の条件（岩のマスの宇宙人を「宇宙人がいる組」に数えない、岩でないマスの宇宙人は数える、行・列・区域の 3 つとも）を確かめる項目が無ければ NG。
2. CR の変えること（core/rules.gd の dead_marks の 3 つのループ）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。
3. 「変わる既存のテスト: なし」と「変わらない既存のテスト」の 19 個が CR に写っているか。名前が main 46fc619 に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1192-r0p）のファイル results/cr1192_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1192.txt）

Rules.dead_marks（× だけの組）の判定の順を、Rules.filled_lines（そろった組）に合わせて（前の調べ results/bug_dead_radar.md の「ついでに見つけたこと」。ユーザーの指示 10/27 18:2x「pixelの確認はもっとまとめて行いたいから改修の実装進めていって」）。
今の dead_marks は、行・列・区域のマスごとに、まずマスの状態を見て、宇宙人なら「宇宙人がいる組」として数え、そのあとで小惑星・レーダーの岩のマスを飛ばす。そのため、岩のマスに宇宙人が置かれた盤では、その行・列・区域の残りが全部 × でも × だけの組にならない。filled_lines は岩のマスを先に飛ばすので、2 つの決まりが食い違っている。CR-1186 で岩のマスに新しく宇宙人は置けなくなったが、それより前に保存した盤では起きうる。
- core/rules.gd の static func dead_marks の、行（y ごと）・列（x ごと）・区域（区域の番号ごと）を調べる 3 つのループの中で、マスごとに、まず小惑星（is_asteroid）かレーダー（is_radar_cell）のマスなら continue で飛ばし、そのあとでマスの状態（board_state.state_at）を見る順にする。状態の見方（宇宙人なら has_alien = true にして break、× なら並びに足す、空なら all_marks = false にして break）は変えない。
- 岩のマスに宇宙人があっても、その行・列・区域は「宇宙人がいる組」に数えない（岩のマスの × も数えない）。返す並び（y の小さい順、y が同じなら x の小さい順）は変えない。
- Rules.filled_lines・Rules.conflicts、ほかの規則の関数、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（行 0 は、レーダーの岩の (0, 0) に宇宙人、ほかの 3 マスが ×。岩のマスは数えないので、行 0 は × だけの組）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]]}) をする（(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3) を順にしたあと（行 3 は、小惑星の (3, 3) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]。続けて b.apply("place", 1, 3) をしたあと（(1, 3) の × を宇宙人に替えた。岩でないマスの宇宙人は「宇宙人がいる組」に数える）の Rules.dead_marks(b, level) は []。
3. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 は、岩の (0, 0) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]。続けて b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（列 0 も、岩の (0, 0) に宇宙人、ほかの 3 マスが × になった）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)]。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session — mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無い（宇宙人を置く 2 つ目の盤は岩でないマスに置き、radar_text_color を見る）ので、dead_marks の値は変わらない
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_without_session — session の無い board_view で、dead_marks を通らない
- test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color — mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無い（宇宙人を置く 2 つ目の盤は岩でないマスに置き、radar_text_color を見る）ので、dead_marks の値は変わらない
- test/cr/test_cr_1173.gd::test_dead_marks_basic — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece — 岩のマスに宇宙人を置く盤では radar_text_color だけを見る。mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無いので、dead_marks の値は変わらない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "pixelの確認はもっとまとめて行いたいから改修の実装進めていって"
  said_at: "2026-10-27 18:2x"
  decision: "ユーザーの指示 10/27 18:2x（判断の一覧の項目なし）"
  plan: "不具合の芽・片づけ（A 組）"
  step: "Rules.dead_marks の判定の順を filled_lines に合わせる（A 組の 2 本目）"
title: "× だけの組の判定で岩のマスを先に飛ばす"
probe: req_cr1192_probe.gd
decls: {}
files:
  edit: [core/rules.gd]
  new: []
human:
  - "自動の項目だけ（今の面では岩のマスに宇宙人が置けないので、画面は変わらない）。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（行 0 は、レーダーの岩の (0, 0) に宇宙人、ほかの 3 マスが ×。岩のマスは数えないので、行 0 は × だけの組）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]。'
  target: Rules.dead_marks
  expect:
  - 'Rules.dead_marks(b, level)'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]]}) をする（(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3) を順にしたあと（行 3 は、小惑星の (3, 3) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]。続けて b.apply("place", 1, 3) をしたあと（(1, 3) の × を宇宙人に替えた。岩でないマスの宇宙人は「宇宙人がいる組」に数える）の Rules.dead_marks(b, level) は []。'
  target: Rules.dead_marks
  expect:
  - 'Rules.dead_marks(b, level)'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 は、岩の (0, 0) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]。続けて b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（列 0 も、岩の (0, 0) に宇宙人、ほかの 3 マスが × になった）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)]。'
  target: Rules.dead_marks
  expect:
  - 'Rules.dead_marks(b, level)'
extra_items: 0
keep:
  files: [game/session.gd, scenes/main.gd, scenes/board_view.gd, scenes/sound.gd]
  other:
  - 'core/rules.gd の Rules.filled_lines と Rules.conflicts は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session'
  - 'test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_without_session'
  - 'test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color'
  - 'test/cr/test_cr_1173.gd::test_dead_marks_basic'
  - 'test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group'
  - 'test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece'
```

## CR（CR-1192-1192v.local.md）

# CR-1192: × だけの組の判定で岩のマスを先に飛ばす

## 変えること
- core/rules.gd の static func dead_marks の、行（y ごと）・列（x ごと）・区域（区域の番号ごと）を調べる 3 つのループの中で、マスごとに、まず小惑星（is_asteroid）かレーダー（is_radar_cell）のマスなら continue で飛ばし、そのあとでマスの状態（board_state.state_at）を見る順にする。状態の見方（宇宙人なら has_alien = true にして break、× なら並びに足す、空なら all_marks = false にして break）は変えない。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/board_state.gd`、`core/deduce.gd`、`core/grid.gd`、`core/hint.gd`、`core/solver.gd`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/`、`test/`、`tools/`、`.autedev/`
- `core/rules.gd`: `conflicts`、`is_solved`、`radar_count`、`radar_conflicts`、`radar_satisfied`、`filled_lines`
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: core/rules.gd の Rules.filled_lines と Rules.conflicts は変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 2, 0)、b.apply("mark", 3, 0) を順にしたあと（行 0 は、レーダーの岩の (0, 0) に宇宙人、ほかの 3 マスが ×。岩のマスは数えないので、行 0 は × だけの組）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]]}) をする（(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 3, 3)、b.apply("mark", 0, 3)、b.apply("mark", 1, 3)、b.apply("mark", 2, 3) を順にしたあと（行 3 は、小惑星の (3, 3) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]。続けて b.apply("place", 1, 3) をしたあと（(1, 3) の × を宇宙人に替えた。岩でないマスの宇宙人は「宇宙人がいる組」に数える）の Rules.dead_marks(b, level) は []。
3. テストの関数の中で var Level = load("res://game/level.gd")、var Rules = load("res://core/rules.gd")、var BS = load("res://core/board_state.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩。区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var b = BS.new(4, 4) とする。b.apply("place", 0, 0)、b.apply("mark", 1, 0)、b.apply("mark", 0, 1)、b.apply("mark", 1, 1) を順にしたあと（区域 0 は、岩の (0, 0) に宇宙人、ほかの 3 マスが ×）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]。続けて b.apply("mark", 0, 2)、b.apply("mark", 0, 3) を順にしたあと（列 0 も、岩の (0, 0) に宇宙人、ほかの 3 マスが × になった）の Rules.dead_marks(b, level) は [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 3)]。
4. 既存のテストがすべて合格する。

## 人が確かめること
- 自動の項目だけ（今の面では岩のマスに宇宙人が置けないので、画面は変わらない）。

## 変わらない既存のテスト
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session — mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無い（宇宙人を置く 2 つ目の盤は岩でないマスに置き、radar_text_color を見る）ので、dead_marks の値は変わらない
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_without_session — session の無い board_view で、dead_marks を通らない
- test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color — mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無い（宇宙人を置く 2 つ目の盤は岩でないマスに置き、radar_text_color を見る）ので、dead_marks の値は変わらない
- test/cr/test_cr_1173.gd::test_dead_marks_basic — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 岩のマスに宇宙人を置く盤を使わない（岩の無い面か、岩のマスには何も置かないか × だけ）ので、dead_marks の値は変わらない
- test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece — 岩のマスに宇宙人を置く盤では radar_text_color だけを見る。mark_color_at を見る盤は、岩のマスに × があるだけで宇宙人が無いので、dead_marks の値は変わらない

## 対象の候補
- edit: `core/rules.gd`
