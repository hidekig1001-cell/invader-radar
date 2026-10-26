# クラウドへの依頼: InvaderRadar改修1181 の R0'（CR.md を読む）（2026-10-27 04:5x、Invader Radar29）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は a12daf1（v1.89-cr1180。1179 の dead と 1180 の vibrate(ms, amplitude) が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は D:\AI\req_cr1181.txt（下に全文）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜3 の手順と期待値を落とさず写しているか。依頼の中心の条件（宇宙人がぶつかって赤くなる手＝ sfx_for が "wrong" の手で 250 ms・強さ 0.3、その手では 30 ms を出さない、ぶつかっている宇宙人を取る手では振動しない、チュートリアルの盤でも同じ）を確かめる項目が無ければ NG。
2. CR の変えること（_refresh の play_sfx の後、"wrong" なら vibrate(250, 0.3)）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。dead・mark・place の振動を変えていないか。
3. 「変わる既存のテスト: なし」「変わらない既存のテスト」の 3 つが CR に写っているか。main a12daf1 の今のテスト（test_cr_1177・test_cr_1179・test_cr_1180 の vibrations の表明）で、wrong の手が入っていて 250 が増えてしまう表明が無いかも見る（あれば「変わる既存のテスト」の抜けとして NG）。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1181-r0p）のファイル results/cr1181_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。

## 依頼（req_cr1181.txt）

宇宙人どうしがぶつかって赤くなる手は、弱めで長めに振動させて（ユーザーの Pixel の確かめ 10/26 22:5x「NGのとき（宇宙人が赤、ｘが赤になるとき）は弱めで長めの時間で振動させて」。× が赤くなる手（CR-1179 の "dead"）は CR-1182 で替える）。
「宇宙人が赤くなる手」は、Sound.sfx_for が "wrong" を返す手（Rules.conflicts の数が前の手より増えた手。例: (0, 0) に宇宙人があるとき、斜め隣の (1, 1) に宇宙人を置いた手）。この手は効果音の順で place より前なので、宇宙人を置いた 30 ミリ秒の振動は出さず、250 ミリ秒・強さ 0.3 の振動だけを出す。ぶつかっている宇宙人を取る手では振動しない。チュートリアルの盤の手も同じに振動する。
強さは CR-1180 で足した sound.vibrate(ms, amplitude) の amplitude（0〜1）で渡す。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "wrong" なら sound.vibrate(250, 0.3) を呼ぶ（vibrate の amplitude は CR-1180 で足したもの）。
- Sound.sfx_for、効果音の鳴らし方、宇宙人を置いたときと × を付けたときの振動、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.session.double_tap(1, 1) をしたあと（斜め隣に宇宙人を置き、2 つがぶつかって赤くなった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.double_tap(0, 3) を順にしたあと（同じ列の 2 つがぶつかった）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(0, 3) をしたあと（ぶつかっていた宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(2, 1) をしたあと（ぶつからない場所に宇宙人を置いた）の m.sound.vibrations は [30, 250, 30]、m.sound.vibration_amplitudes は [-1.0, 0.3, -1.0]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.double_tap(2, 1) をしたあと（チュートリアルの盤で同じ行の隣に置き、ぶつかった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — 宇宙人はぶつからない 1 つだけ置くので wrong にならない
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — Sound.sfx_for は変えない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — チュートリアルの wrong の手も振動するが、見ているのは効果音だけ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "NGのとき（宇宙人が赤、ｘが赤になるとき）は弱めで長めの時間で振動させて"
  said_at: "2026-10-26 22:5x"
  decision: "D-20261026-0622"
  plan: "スマホの振動（置いたとき・× だけの組ができたとき・× を付けたとき・ぶつかったとき）"
  step: "宇宙人がぶつかった手で 250 ミリ秒・強さ 0.3 で振動する（CR 5 つ目）"
title: "宇宙人がぶつかったとき弱め・長めに振動する"
probe: req_cr1181_probe.gd
decls: {}
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel で宇宙人を隣どうしに置いて赤くなったとき、宇宙人を置いたときより弱く、長くブーッと振動することを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.session.double_tap(1, 1) をしたあと（斜め隣に宇宙人を置き、2 つがぶつかって赤くなった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。'
  target: m.session.double_tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.double_tap(0, 3) を順にしたあと（同じ列の 2 つがぶつかった）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(0, 3) をしたあと（ぶつかっていた宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(2, 1) をしたあと（ぶつからない場所に宇宙人を置いた）の m.sound.vibrations は [30, 250, 30]、m.sound.vibration_amplitudes は [-1.0, 0.3, -1.0]。'
  target: m.session.double_tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.double_tap(2, 1) をしたあと（チュートリアルの盤で同じ行の隣に置き、ぶつかった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。'
  target: m.tutorial.session.double_tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, game/tutorial.gd, scenes/board_view.gd, scenes/sound.gd]
  other:
  - 'scenes/main.gd の宇宙人を置いたときの sound.vibrate(30) と × を付けたときの sound.vibrate(15, 0.4) は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_wrong'
  - 'test/cr/test_cr_1038.gd::test_tutorial_wrong_sound'
```

## CR（CR-1181-1181v.local.md）

# CR-1181: 宇宙人がぶつかったとき弱め・長めに振動する

## 変えること
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "wrong" なら sound.vibrate(250, 0.3) を呼ぶ（vibrate の amplitude は CR-1180 で足したもの）。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`last_dead`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: game/tutorial.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd の宇宙人を置いたときの sound.vibrate(30) と × を付けたときの sound.vibrate(15, 0.4) は変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.session.double_tap(1, 1) をしたあと（斜め隣に宇宙人を置き、2 つがぶつかって赤くなった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0)、m.session.double_tap(0, 3) を順にしたあと（同じ列の 2 つがぶつかった）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(0, 3) をしたあと（ぶつかっていた宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [30, 250]。続けて m.session.double_tap(2, 1) をしたあと（ぶつからない場所に宇宙人を置いた）の m.sound.vibrations は [30, 250, 30]、m.sound.vibration_amplitudes は [-1.0, 0.3, -1.0]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.double_tap(2, 1) をしたあと（チュートリアルの盤で同じ行の隣に置き、ぶつかった）の m.sound.vibrations は [30, 250]、m.sound.vibration_amplitudes は [-1.0, 0.3]。
4. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で宇宙人を隣どうしに置いて赤くなったとき、宇宙人を置いたときより弱く、長くブーッと振動することを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — 宇宙人はぶつからない 1 つだけ置くので wrong にならない
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — Sound.sfx_for は変えない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — チュートリアルの wrong の手も振動するが、見ているのは効果音だけ

## 対象の候補
- edit: `scenes/main.gd`
