# クラウドセッションへの依頼: IR CR-1178 の R0'（2 回目、CR.md を読む）（2026-10-26 19:1x、Invader Radar改修28）

- repository: hidekig1001-cell/invader-radar（private）、土台は main（8b632f5、v1.83-cr1174）。

## 依頼の文

リポジトリ hidekig1001-cell/invader-radar の main（8b632f5）を読める状態で、下の「依頼（req_cr1178.txt）」と、AuteDev の CR を作る役（Ubuntu4 の Qwen-next-flash）が作った「CR（CR-1178-1178v.local.md）」を読み比べ、R0'（CR の確認）の OK／NG を決めてください。アプリのコードは書き換えないこと。回答は日本語で。

これは 2 回目です。1 回目（GLM の CR）は、依頼に無い「期待値を外す」箇条が足され、「画面の文言」の表が文を変えるように書かれていて NG でした。今回は依頼の最後の期待値を「m.bubble.text は m.help_text() の値と同じ」に替えてから作り直しました。

### 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1 の手順と期待値（size_up_wait が 0.6、tick_size_up(0.7) の後にタイルが出る、出てすぐのタップでは消えない、tick_size_up(1.0) の後のタップで消えて m.bubble.text が m.help_text() と同じ）を落とさず写しているか。依頼の中心の条件（0.6 秒後に出す・出て 0.8 秒は消さない）を確かめる項目が無ければ NG。
2. 「変わる既存のテスト」（test/cr/test_cr_1172.gd の 2 関数）の書き直し方（m.tick_size_up(0.7) と m.tick_size_up(1.0) の行を足す、表明は変えない）が CR に写っていて、main の test/cr/test_cr_1172.gd でその足し方で通る筋か。
3. 「変わらない既存のテスト」（test_cr_1167・test_pixel_1023）が変わらずに通るか、main の scenes/main.gd の _refresh・_on_touch_down・_process・help_text を読んで確かめる。
4. CR の変えること（scenes/main.gd だけ）が依頼の 5 行と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。「画面の文言」の表があれば、文を変えるように見えないか。

### 終わりの条件（必ず守る）
- 結果を、branch `review/cr1178-r0p-2` を main から作り、ファイル `results/cr1178_r0p_2.md` に書いて commit・push する。ファイルの 1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。
- 最後の返答にも同じ 1 行目を書く。

## 依頼（req_cr1178.txt）

盤が大きくなる面のお知らせを、次の面の盤を見せてから出し、出てすぐのタップでは消えないようにして（ユーザーの Pixel の確かめ 10/26 06:2x、確認ポイント 4: 一瞬表示されたような気もするが、ほぼ見えない。クリア、タップ、次の面の盤、その画面でマスが増えて難しくなるよ、の表示にして）。今はタップと同時にクリアのタイルと同じ場所にお知らせのタイルが出るので、続けたタップですぐ消える。
- scenes/main.gd に var size_up_wait: float = 0.0（お知らせを出すまでの残りの秒）と var size_up_age: float = 0.0（お知らせが出てからの秒）を足す。
- scenes/main.gd の func _refresh で、クリアの文を消す所（bubble.text == cleared_text() のとき bubble.clear_text() の後）で size_up_tile_text() が "" でないときは、bubble.show_tile を呼ぶ代わりに size_up_wait = 0.6 にする（"" なら今と同じく show_help() をする）。
- scenes/main.gd に func tick_size_up(delta: float) -> void を足す。size_up_wait が 0 より大きいときは delta を引き、0 以下になったら size_up_wait = 0.0・size_up_age = 0.0 にして bubble.show_tile(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) をして終わる。size_up_wait が 0 で、bubble.tile_mode が true で bubble.text が size_up_tile_text() と同じなら size_up_age に delta を足す。毎フレームの処理（func _process）で、最初の return の判定の後、session.tick(delta) の前に tick_size_up(delta) を呼ぶ。
- scenes/main.gd の func _on_touch_down で、_stroke = [] の後、チュートリアルでなく size_up_wait が 0 より大きいときは何もせず return する。お知らせのタイルを消す所（bubble.tile_mode が true で bubble.text が size_up_tile_text() のとき）は、size_up_age が 0.8 より小さければ何もせず return し、0.8 以上なら今と同じく bubble.clear_text() と show_help() をして return する。
- お知らせの文（size_up_text・size_up_tile_text）、クリアのタイルの文と出し方、吹き出しの部品（scenes/message_bubble.gd）、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var MS = load("res://scenes/main.tscn") とする。var l1 = Level.new() として l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]}) をし、var l2 = Level.new() として l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]}) をし、var l3 = Level.new() として l3.parse に l2 と同じ辞書の "id" を 3 にしたものを渡す（2 面が最後の面にならないように）。var s = SessionScript.new([l1, l2, l3]) とし、var m = MS.instantiate() として m.language = "ja" と m.session = s をし、add_child_autofree(m) して await wait_frames(2) をする。s.solve_now() をする。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) にする。m._input(down) をしたあと（クリアの後のタップで次の面へ）の s.level_index は 1 で、m.bubble.tile_mode は false で、m.size_up_wait は 0.6。m.tick_size_up(0.7) をしたあとの m.bubble.tile_mode は true で、m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる"。続けて m._input(down) をしたあとの m.bubble.tile_mode は true（出てすぐのタップでは消えない）。続けて m.tick_size_up(1.0) をしてから m._input(down) をしたあとの m.bubble.tile_mode は false で、m.bubble.text は m.help_text() の値と同じ（タイルを消したあとにヘルプの文に戻る）。

変わる既存のテスト:
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 次の面に進んで 1 フレーム後にお知らせのタイルが出て、すぐのタップで消えることを確かめている。お知らせは 0.6 秒後に出て、出てから 0.8 秒たつまで消えないので、s.next_level() と await wait_frames(1) の後（assert_true(m.bubble.tile_mode) の前）に m.tick_size_up(0.7) の行を足し、m._input(down) の前に m.tick_size_up(1.0) の行を足す。表明は 1 つも変えず、足した 2 行の後で今の表明が全部通る。
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — 次の面に進んで 1 フレーム後にお知らせのタイルが出ることを確かめている。s.next_level() と await wait_frames(1) の後（assert_true(m.bubble.tile_mode) の前）に m.tick_size_up(0.7) の行を足す。表明は 1 つも変えず、足した行の後で今の表明が全部通る。

変わらない既存のテスト:
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — お知らせの文（size_up_text）と操作の説明を確かめている。文は変えないので、この CR の後も通る。
- test/cr/test_pixel_1023.gd::test_pixel_1023_help_text_after_next_level_and_ja — 1 面から 2 面に進んだあとの吹き出しの文を確かめている。2 面は 1 面と同じ 4×4 でお知らせが無いので、この CR の後も通る。

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "4一瞬表示されたような気もするが、ほぼ見えない。表示のタイミングも、クリアー、タップ、次の面の盤面、その画面でここからはマスが増えて難しくしてなるよ、の表示にして。"
  said_at: "2026-10-26 06:28"
  decision: "D-20261026-0622"
  plan: "Pixel の確かめ（8b632f5）の指摘を直す"
  step: "お知らせを次の面の盤を見せてから出し、出てすぐのタップでは消さない（CR 1 つ）"
title: "盤が大きくなる面のお知らせを盤を見せてから出す"
probe: req_cr1178_probe.gd
decls:
  scenes/main.gd:
  - "var size_up_wait: float = 0.0"
  - "var size_up_age: float = 0.0"
  - "func tick_size_up(delta: float) -> void"
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel で 5 面をクリアし、タップで 6 面に進むと、まず 5×5 の盤が見え、少し（0.6 秒）たってから盤のまん中のタイルにお知らせが出て、しばらく読めることを見る。続けてすぐタップしても消えず、少し待ってからのタップで消えて遊べることを見る（English も）。"
  - "7 面に進むときはお知らせが出ず、すぐ遊べることを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var MS = load("res://scenes/main.tscn") とする。var l1 = Level.new() として l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]}) をし、var l2 = Level.new() として l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]}) をし、var l3 = Level.new() として l3.parse に l2 と同じ辞書の "id" を 3 にしたものを渡す（2 面が最後の面にならないように）。var s = SessionScript.new([l1, l2, l3]) とし、var m = MS.instantiate() として m.language = "ja" と m.session = s をし、add_child_autofree(m) して await wait_frames(2) をする。s.solve_now() をする。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) にする。m._input(down) をしたあと（クリアの後のタップで次の面へ）の s.level_index は 1 で、m.bubble.tile_mode は false で、m.size_up_wait は 0.6。m.tick_size_up(0.7) をしたあとの m.bubble.tile_mode は true で、m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる"。続けて m._input(down) をしたあとの m.bubble.tile_mode は true（出てすぐのタップでは消えない）。続けて m.tick_size_up(1.0) をしてから m._input(down) をしたあとの m.bubble.tile_mode は false で、m.bubble.text は m.help_text() の値と同じ（タイルを消したあとにヘルプの文に戻る）。'
  target: m.tick_size_up
  expect:
  - 'm.bubble.tile_mode'
  - 'm.bubble.text'
  - 'm.size_up_wait'
extra_items: 0
keep:
  files:
  - scenes/message_bubble.gd
  - game/session.gd
  - scenes/board_view.gd
  other:
  - 'scenes/main.gd のお知らせの文（size_up_text・size_up_tile_text）と、クリアのタイルの文と出し方は変えない'
changing_tests:
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en
unchanged_tests:
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja
- test/cr/test_pixel_1023.gd::test_pixel_1023_help_text_after_next_level_and_ja
```


## CR（CR-1178-1178v.local.md）

# CR-1178: 盤が大きくなる面のお知らせを盤を見せてから出す

## 変えること
- scenes/main.gd に var size_up_wait: float = 0.0（お知らせを出すまでの残りの秒）と var size_up_age: float = 0.0（お知らせが出てからの秒）を足す。
- scenes/main.gd の func _refresh で、クリアの文を消す所（bubble.text == cleared_text() のとき bubble.clear_text() の後）で size_up_tile_text() が "" でないときは、bubble.show_tile を呼ぶ代わりに size_up_wait = 0.6 にする（"" なら今と同じく show_help() をする）。
- scenes/main.gd に func tick_size_up(delta: float) -> void を足す。size_up_wait が 0 より大きいときは delta を引き、0 以下になったら size_up_wait = 0.0・size_up_age = 0.0 にして bubble.show_tile(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) をして終わる。size_up_wait が 0 で、bubble.tile_mode が true で bubble.text が size_up_tile_text() と同じなら size_up_age に delta を足す。毎フレームの処理（func _process）で、最初の return の判定の後、session.tick(delta) の前に tick_size_up(delta) を呼ぶ。
- scenes/main.gd の func _on_touch_down で、_stroke = [] の後、チュートリアルでなく size_up_wait が 0 より大きいときは何もせず return する。お知らせのタイルを消す所（bubble.tile_mode が true で bubble.text が size_up_tile_text() のとき）は、size_up_age が 0.8 より小さければ何もせず return し、0.8 以上なら今と同じく bubble.clear_text() と show_help() をして return する。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`sound`、`last_snapshot`、`last_conflicts`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`hud`、`base_positions`、`rules_panel`、`title_logo`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`dead_marks_text`、`size_up_text`、`is_last_level`、`go_back`、`on_title_requested`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: scenes/message_bubble.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd のお知らせの文（size_up_text・size_up_tile_text）と、クリアのタイルの文と出し方は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/main.gd` に足す（既存のファイルに足す）
  - `var size_up_wait: float = 0.0`
  - `var size_up_age: float = 0.0`
  - `func tick_size_up(delta: float) -> void`

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var MS = load("res://scenes/main.tscn") とする。var l1 = Level.new() として l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]}) をし、var l2 = Level.new() として l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]}) をし、var l3 = Level.new() として l3.parse に l2 と同じ辞書の "id" を 3 にしたものを渡す（2 面が最後の面にならないように）。var s = SessionScript.new([l1, l2, l3]) とし、var m = MS.instantiate() として m.language = "ja" と m.session = s をし、add_child_autofree(m) して await wait_frames(2) をする。s.solve_now() をする。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) にする。m._input(down) をしたあと（クリアの後のタップで次の面へ）の s.level_index は 1 で、m.bubble.tile_mode は false で、m.size_up_wait は 0.6。m.tick_size_up(0.7) をしたあとの m.bubble.tile_mode は true で、m.bubble.text は "この面からはマスが 5×5 になるよ。\nがんばって！  タップではじめる"。続けて m._input(down) をしたあとの m.bubble.tile_mode は true（出てすぐのタップでは消えない）。続けて m.tick_size_up(1.0) をしてから m._input(down) をしたあとの m.bubble.tile_mode は false で、m.bubble.text は m.help_text() の値と同じ（タイルを消したあとにヘルプの文に戻る）。
2. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で 5 面をクリアし、タップで 6 面に進むと、まず 5×5 の盤が見え、少し（0.6 秒）たってから盤のまん中のタイルにお知らせが出て、しばらく読めることを見る。続けてすぐタップしても消えず、少し待ってからのタップで消えて遊べることを見る（English も）。
- 7 面に進むときはお知らせが出ず、すぐ遊べることを見る。

## 変わる既存のテスト
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 次の面に進んで 1 フレーム後にお知らせのタイルが出て、すぐのタップで消えることを確かめている。お知らせは 0.6 秒後に出て、出てから 0.8 秒たつまで消えないので、s.next_level() と await wait_frames(1) の後（assert_true(m.bubble.tile_mode) の前）に m.tick_size_up(0.7) の行を足し、m._input(down) の前に m.tick_size_up(1.0) の行を足す。表明は 1 つも変えず、足した 2 行の後で今の表明が全部通る。
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — 次の面に進んで 1 フレーム後にお知らせのタイルが出ることを確かめている。s.next_level() と await wait_frames(1) の後（assert_true(m.bubble.tile_mode) の前）に m.tick_size_up(0.7) の行を足す。表明は 1 つも変えず、足した行の後で今の表明が全部通る。

## 変わらない既存のテスト
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — お知らせの文（size_up_text）と操作の説明を確かめている。文は変えないので、この CR の後も通る。
- test/cr/test_pixel_1023.gd::test_pixel_1023_help_text_after_next_level_and_ja — 1 面から 2 面に進んだあとの吹き出しの文を確かめている。2 面は 1 面と同じ 4×4 でお知らせが無いので、この CR の後も通る。

## 対象の候補
- edit: `scenes/main.gd`
