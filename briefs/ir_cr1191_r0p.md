# クラウドへの依頼: InvaderRadar改修1191 の R0'（CR.md を読む）（1 回目、2026-10-27 19:5x、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 2f8272f（v1.98-cr1189。1189 の「最初の _refresh で音と振動を出さない」が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、クラウドが下書きした draft/next-a の drafts/req_cleanup_last_dead.txt（probe の名前だけ手元の req_cr1191_probe.gd に替えた）。使われない var last_dead と、値を入れる 3 行を消し、test_cr_1187_undo_dead_group の迷いのコメントを片づける（振る舞いは変えない）。CR は AuteDev の CR を作る役が、main 2f8272f から作った。
手元の当て試し（main 46fc619 の写し）では、直しを当てると 751 件すべて通り、直しなしでは probe の 2 件だけが落ちた。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（end_tutorial の var marks と last_dead_marks = marks は残す、last_dead_marks・last_lines・dead と line の決まり・効果音と振動・ほかのファイルは変えない、1189 で足した _refresh の 2 行も変えない）が CR の変えることか確かめる項目に写っているかを見る。
- 依頼の箇条が「結果の言い直し」に読まれて CR から落ちることがある（1192）。依頼の箇条が CR の変えることに全部あるかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1・2 の手順と期待値（"last_dead" in m が false、"last_dead_marks" in m が true、区域 0・区域 3 で dead が 1 回・2 回、振動の値まるごと、チュートリアルの前後）を落とさず写しているか。依頼の中心の条件（last_dead が無くなる、dead の振る舞いは 1187 のまま）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/main.gd の宣言と 3 行を消す、test_cr_1187.gd のコメントの片づけ）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。消す 3 行の場所（_refresh・start_tutorial・end_tutorial）が main 2f8272f の行と合っているか。
3. 「変わる既存のテスト」の test_cr_1187_undo_dead_group（表明と手は変わらず、コメントだけ）と、「変わらない既存のテスト」が CR に写っているか。名前が main 2f8272f に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1191-r0p）のファイル results/cr1191_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1191.txt）

使われていない変数 last_dead を消して、テストに残った迷いのコメントを片づけて（InvaderRadar改修1187 の差分の読みで見つかった片づけ。ユーザーの指示 10/27 18:2x「pixelの確認はもっとまとめて行いたいから改修の実装進めていって」）。
scenes/main.gd の var last_dead は、1187 で dead の決まりが last_dead_marks（× だけの組のマスの並び）に替わってから、宣言・_refresh・start_tutorial・end_tutorial の 4 か所で書くだけで、どこからも読まれていない。振る舞いは変えない片づけ。
- scenes/main.gd の var last_dead: bool = false の宣言を消す。
- scenes/main.gd の、last_dead に値を入れる 3 行を消す。func _refresh の last_dead = not curr_dead_marks.is_empty()、func start_tutorial の last_dead = false、func end_tutorial の last_dead = not marks.is_empty() の 3 行。end_tutorial の var marks = Rules.dead_marks(session.board, session.level) と last_dead_marks = marks、ほかの行は残す。
- last_dead_marks・last_lines、dead・line の決まり、効果音と振動、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。"last_dead" in m は false（変数 last_dead が無くなった）、"last_dead_marks" in m は true（dead の決まりの変数は残る）。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(2, 2)、m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 3 も × だけで埋まった。2 つ目の組でも dead が鳴る）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしたあとの "last_dead" in m は false。続けて m.end_tutorial() をしたあとの "last_dead" in m は false。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。

変わる既存のテスト:
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 表明と手は変わらない。コメントだけが変わる: `assert_eq(m.sound.played[-1], "line") # Or whatever sfx corresponds to clearing the dead state / placing alien. The prompt says "line" for this step in test 3 description? ` は `assert_eq(m.sound.played[-1], "line")` に変わる。`assert_eq(m.sound.vibrations, [15, 15, 15, 250]) # No new vibration for line? Or maybe line has no vibration in this context? ` は `assert_eq(m.sound.vibrations, [15, 15, 15, 250])` に変わる。「# Wait, prompt says」「# Actually, looking at CR-1187」「# If we place an alien」「# The prompt explicitly says」「# This implies the double_tap」「# Ah, `Rules.filled_lines`」「# Let's trust the prompt」で始まる 7 行のコメントは消える。「# Fill region 0 with X」「# Double tap (1,1) to place alien.」「# Undo: (1,1) becomes X again.」の 3 行のコメントは変わらない

変わらない既存のテスト:
- test/cr/test_cr_1012.gd::test_tutorial_starts_with_correct_state — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_input_double_tap_advances_step — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_ends_and_restores_state — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1018.gd::test_settings_pressed_does_not_restart_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1018.gd::test_tutorial_finished_signal_emitted — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1026.gd::test_main_cleared_text_ja — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step0 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step1 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step2 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1073.gd::test_main_clear_effect_integration — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1077.gd::test_cr_1077_check_3 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1078.gd::test_cr_1078_no_clear_effect_on_tutorial_input — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_1 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_2 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_3 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1084.gd::test_cr_1084_tutorial_clears_tile_mode_and_shows_text — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_start_tutorial_shows_panel_and_advances — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_end_tutorial_restores_bubble — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_panel_does_not_overlap_ui_or_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1092.gd::test_cr_1092_main_tutorial_blocks_hint — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_pixel_1023_layout.gd::test_bubble_does_not_overlap_buttons_or_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — dead の決まり（last_dead_marks）は変えない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — dead の決まり（last_dead_marks）は変えない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "pixelの確認はもっとまとめて行いたいから改修の実装進めていって"
  said_at: "2026-10-27 18:2x"
  decision: "ユーザーの指示 10/27 18:2x（判断の一覧の項目なし）"
  plan: "不具合の芽・片づけ（A 組）"
  step: "使われない last_dead とテストの迷いのコメントの片づけ（A 組の 1 本目）"
title: "使われない last_dead を消す片づけ"
probe: req_cr1191_probe.gd
decls: {}
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "自動の項目だけ（画面と音は変わらない）。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。"last_dead" in m は false（変数 last_dead が無くなった）、"last_dead_marks" in m は true（dead の決まりの変数は残る）。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(2, 2)、m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 3 も × だけで埋まった。2 つ目の組でも dead が鳴る）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。'
  target: m.session.tap
  expect:
  - '"last_dead" in m'
  - 'm.sound.vibrations'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしたあとの "last_dead" in m は false。続けて m.end_tutorial() をしたあとの "last_dead" in m は false。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。'
  target: m.end_tutorial
  expect:
  - '"last_dead" in m'
  - 'm.sound.vibrations'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, scenes/sound.gd, scenes/board_view.gd]
  other:
  - 'scenes/main.gd の last_dead_marks・last_lines と、dead・line の決まりは変えない'
changing_tests:
  - 'test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group'
unchanged_tests:
  - 'test/cr/test_cr_1012.gd::test_tutorial_starts_with_correct_state'
  - 'test/cr/test_cr_1012.gd::test_tutorial_input_double_tap_advances_step'
  - 'test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board'
  - 'test/cr/test_cr_1012.gd::test_tutorial_ends_and_restores_state'
  - 'test/cr/test_cr_1018.gd::test_settings_pressed_does_not_restart_tutorial'
  - 'test/cr/test_cr_1018.gd::test_tutorial_finished_signal_emitted'
  - 'test/cr/test_cr_1026.gd::test_main_cleared_text_ja'
  - 'test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step0'
  - 'test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step1'
  - 'test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step2'
  - 'test/cr/test_cr_1038.gd::test_tutorial_place_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_mark_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_wrong_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_init_last_values'
  - 'test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates'
  - 'test/cr/test_cr_1073.gd::test_main_clear_effect_integration'
  - 'test/cr/test_cr_1077.gd::test_cr_1077_check_3'
  - 'test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve'
  - 'test/cr/test_cr_1078.gd::test_cr_1078_no_clear_effect_on_tutorial_input'
  - 'test/cr/test_cr_1083.gd::test_cr_1083_check_1'
  - 'test/cr/test_cr_1083.gd::test_cr_1083_check_2'
  - 'test/cr/test_cr_1083.gd::test_cr_1083_check_3'
  - 'test/cr/test_cr_1084.gd::test_cr_1084_tutorial_clears_tile_mode_and_shows_text'
  - 'test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile'
  - 'test/cr/test_cr_1086.gd::test_cr_1086_start_tutorial_shows_panel_and_advances'
  - 'test/cr/test_cr_1086.gd::test_cr_1086_end_tutorial_restores_bubble'
  - 'test/cr/test_cr_1086.gd::test_cr_1086_panel_does_not_overlap_ui_or_board'
  - 'test/cr/test_cr_1092.gd::test_cr_1092_main_tutorial_blocks_hint'
  - 'test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial'
  - 'test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial'
  - 'test/cr/test_pixel_1023_layout.gd::test_bubble_does_not_overlap_buttons_or_board'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line'
```

## CR（CR-1191-1191v.local.md）

# CR-1191: 使われない last_dead を消す片づけ

## 変えること
- scenes/main.gd の var last_dead: bool = false の宣言を消す。
- scenes/main.gd の、last_dead に値を入れる 3 行を消す。func _refresh の last_dead = not curr_dead_marks.is_empty()、func start_tutorial の last_dead = false、func end_tutorial の last_dead = not marks.is_empty() の 3 行。end_tutorial の var marks = Rules.dead_marks(session.board, session.level) と last_dead_marks = marks、ほかの行は残す。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd の last_dead_marks・last_lines と、dead・line の決まりは変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。"last_dead" in m は false（変数 last_dead が無くなった）、"last_dead_marks" in m は true（dead の決まりの変数は残る）。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(2, 2)、m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 3 も × だけで埋まった。2 つ目の組でも dead が鳴る）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしたあとの "last_dead" in m は false。続けて m.end_tutorial() をしたあとの "last_dead" in m は false。続けて m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。
3. 既存のテストがすべて合格する。

## 人が確かめること
- 自動の項目だけ（画面と音は変わらない）。

## 変わる既存のテスト
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 表明と手は変わらない。コメントだけが変わる: `assert_eq(m.sound.played[-1], "line") # Or whatever sfx corresponds to clearing the dead state / placing alien. The prompt says "line" for this step in test 3 description? ` は `assert_eq(m.sound.played[-1], "line")` に変わる。`assert_eq(m.sound.vibrations, [15, 15, 15, 250]) # No new vibration for line? Or maybe line has no vibration in this context? ` は `assert_eq(m.sound.vibrations, [15, 15, 15, 250])` に変わる。「# Wait, prompt says」「# Actually, looking at CR-1187」「# If we place an alien」「# The prompt explicitly says」「# This implies the double_tap」「# Ah, `Rules.filled_lines`」「# Let's trust the prompt」で始まる 7 行のコメントは消える。「# Fill region 0 with X」「# Double tap (1,1) to place alien.」「# Undo: (1,1) becomes X again.」の 3 行のコメントは変わらない

## 変わらない既存のテスト
- test/cr/test_cr_1012.gd::test_tutorial_starts_with_correct_state — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_input_double_tap_advances_step — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1012.gd::test_tutorial_ends_and_restores_state — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1018.gd::test_settings_pressed_does_not_restart_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1018.gd::test_tutorial_finished_signal_emitted — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1026.gd::test_main_cleared_text_ja — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step0 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step1 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1037.gd::test_main_tutorial_bubble_ja_step2 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1073.gd::test_main_clear_effect_integration — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1077.gd::test_cr_1077_check_3 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1078.gd::test_cr_1078_no_clear_effect_on_tutorial_input — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_1 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_2 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1083.gd::test_cr_1083_check_3 — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1084.gd::test_cr_1084_tutorial_clears_tile_mode_and_shows_text — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_start_tutorial_shows_panel_and_advances — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_end_tutorial_restores_bubble — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1086.gd::test_cr_1086_panel_does_not_overlap_ui_or_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1092.gd::test_cr_1092_main_tutorial_blocks_hint — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_pixel_1023_layout.gd::test_bubble_does_not_overlap_buttons_or_board — start_tutorial・end_tutorial・_refresh を通るが、消すのはどこからも読まれない last_dead だけなので、振る舞いは変わらない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — dead の決まり（last_dead_marks）は変えない
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — dead の決まり（last_dead_marks）は変えない

## 対象の候補
- edit: `scenes/main.gd`
