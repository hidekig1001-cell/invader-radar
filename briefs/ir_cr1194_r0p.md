# クラウドへの依頼: InvaderRadar改修1194 の R0'（CR.md を読む）（1 回目、2026-10-27 21:xx、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 8111de3（v2.00-cr1192）か、1193 が入っていればその版。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、クラウドが下書きした draft/next-c の drafts/req_size_up_no_tap.txt（probe の名前だけ手元の req_cr1194_probe.gd に替えた）。盤が大きくなる面のお知らせの札（size_up_tile_text）の終わりの「  タップではじめる」と英語の「  TAP TO START」を消す。ユーザーの原文「「タップで始める」はいらない」（10/27 21:0x、Pixel の確かめ）。CR は AuteDev の CR を作る役が作った。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183・1192）。決まり（0.8 秒たったらタップで消える決まり・金色の札・弾み・音と振動・クリアの札と全部クリアの札の文・size_up_text は変えない）が CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値（札の文の値まるごと、日本語と英語）を落とさず写しているか。依頼の中心の条件（札の文から「タップではじめる」が消える、ほかの札の文は変わらない）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/main.gd の size_up_tile_text の 2 つの文）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。
3. 「変わる既存のテスト」の 3 つ（test_cr_1172_size_up_tile_ja・test_cr_1172_size_up_tile_en・test_cr_1178_size_up_wait_and_age）の変わる表明が、依頼どおりに CR に写っているか。変わらない既存のテストも写っているか。名前が main に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1194-r0p）のファイル results/cr1194_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1194.txt）

盤が大きくなる面の金色のお知らせから「タップではじめる」を消して（ユーザーの指示 10/27 21:0x「８　OK,「タップで始める」はいらない。」。8 は 6 面に進んだときの金色のお知らせ、CR-1188）。
- scenes/main.gd の func size_up_tile_text が返す文の終わりの「  タップではじめる」（日本語）と「  TAP TO START」（英語）を消し、"この面からはマスが %d×%d になるよ。\nがんばって！" と "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!" を返す。札が出て 0.8 秒たったらタップで消える決まり、金色の札・弾み・音と振動、size_up_text とほかの札（クリア・全部クリア）の文、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "ja"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "en"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。

変わる既存のテスト:
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 27 行目の m.bubble.text の期待値 "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる" は "この面からはマスが 5×5 になるよ。\nがんばって！" に変わる
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — 62 行目の m.size_up_tile_text() の期待値と 63 行目の m.bubble.text の期待値 "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START" は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!" に変わる
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — 39 行目の m.bubble.text の期待値 "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる" は "この面からはマスが 5×5 になるよ。\nがんばって！" に変わる

変わらない既存のテスト:
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — size_up_text（札でない文）は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en — size_up_text（札でない文）は変えない
- test/cr/test_cr_1188.gd::test_cr_1188_show_size_up_state — show_size_up の決まり（金色・字の大きさ）は変えない
- test/cr/test_cr_1188.gd::test_cr_1188_size_up_pop_scale — 弾みの決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_step_pop — 弾みの決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_clear_text_restores_size_up — clear_text の決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_main_integration — 札の文そのものは見ず、size_up_mode・0.8 秒・音と振動を見る

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "８　OK,「タップで始める」はいらない。"
  said_at: "2026-10-27 21:0x"
  decision: "ユーザーの指示 10/27 21:0x（Pixel の確かめの追加の依頼）"
  plan: "Pixel の確かめで出た追加の依頼（C 組）"
  step: "大きくなる面のお知らせから「タップではじめる」を消す（C 組の 2 本目）"
title: "大きくなる面のお知らせからタップを消す"
probe: req_cr1194_probe.gd
decls: {}
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel で 6 面に進んで、金色のお知らせが 2 行で「タップではじめる」が無いこと、0.8 秒たってタップで消えることを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "ja"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。'
  target: m.size_up_tile_text
  expect:
  - 'm.size_up_tile_text()'
  - 'm.bubble.text'
  - 'm.bubble.get_line_count()'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "en"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。'
  target: m.size_up_tile_text
  expect:
  - 'm.size_up_tile_text()'
  - 'm.bubble.text'
  - 'm.bubble.get_line_count()'
extra_items: 0
keep:
  files: [scenes/message_bubble.gd, scenes/sound.gd, game/session.gd]
  other:
  - 'size_up_text と、クリア・全部クリアの札の文は変えない'
  - 'show_size_up の字の大きさ（上限 52・下限 36）は変えない'
changing_tests:
  - 'test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja'
  - 'test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en'
  - 'test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age'
unchanged_tests:
  - 'test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja'
  - 'test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_show_size_up_state'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_size_up_pop_scale'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_step_pop'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_clear_text_restores_size_up'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_main_integration'
```

## CR（CR-1194-1194v.local.md）

# CR-1194: 大きくなる面のお知らせからタップを消す

## 変えること
- scenes/main.gd の func size_up_tile_text が返す文の終わりの「 タップではじめる」（日本語）と「 TAP TO START」（英語）を消し、"この面からはマスが %d×%d になるよ。\nがんばって！" と "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!" を返す。札が出て 0.8 秒たったらタップで消える決まり、金色の札・弾み・音と振動、size_up_text とほかの札（クリア・全部クリア）の文、ほかのファイルは変えない。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`sound`、`last_snapshot`、`last_conflicts`、`last_dead`、`last_dead_marks`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: scenes/message_bubble.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: size_up_text と、クリア・全部クリアの札の文は変えない（依頼の欄）
- 依頼の欄: show_size_up の字の大きさ（上限 52・下限 36）は変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "ja"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、4×4 の面 l1（l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})）と、5×5 の面 l2・l3（id 2・3、width 5、height 5、target 5、regions は行ごとに 0〜4 の区域）を作る。var m = load("res://scenes/main.tscn").instantiate() として m.language = "en"、m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと、位置 Vector2(540, 300) を押す InputEventScreenTouch（index 0、pressed true）を m._input に渡し（クリアの札を消して 5×5 の面に進む）、m.tick_size_up(0.7) をする（0.6 秒の待ちが過ぎて、お知らせの札が出る）。そのあとの m.size_up_tile_text() と m.bubble.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!"、m.bubble.size_up_mode は true、m.bubble.get_line_count() は 2。
3. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で 6 面に進んで、金色のお知らせが 2 行で「タップではじめる」が無いこと、0.8 秒たってタップで消えることを見る。

## 変わる既存のテスト
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 27 行目の m.bubble.text の期待値 "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる" は "この面からはマスが 5×5 になるよ。\nがんばって！" に変わる
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — 62 行目の m.size_up_tile_text() の期待値と 63 行目の m.bubble.text の期待値 "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START" は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!" に変わる
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — 39 行目の m.bubble.text の期待値 "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる" は "この面からはマスが 5×5 になるよ。\nがんばって！" に変わる

## 変わらない既存のテスト
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — size_up_text（札でない文）は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en — size_up_text（札でない文）は変えない
- test/cr/test_cr_1188.gd::test_cr_1188_show_size_up_state — show_size_up の決まり（金色・字の大きさ）は変えない
- test/cr/test_cr_1188.gd::test_cr_1188_size_up_pop_scale — 弾みの決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_step_pop — 弾みの決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_clear_text_restores_size_up — clear_text の決まりは変えない
- test/cr/test_cr_1188.gd::test_cr_1188_main_integration — 札の文そのものは見ず、size_up_mode・0.8 秒・音と振動を見る

## 対象の候補
- edit: `scenes/main.gd`
