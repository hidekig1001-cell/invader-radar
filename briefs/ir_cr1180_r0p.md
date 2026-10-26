# クラウドへの依頼: InvaderRadar改修1180 の R0'（CR.md を読む）（2026-10-27 00:4x、Invader Radar28）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は e6cf4ca。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きした draft/cr1180 の req_cr1180.txt の、依頼の欄の changes を AuteDev の形（file・func・add_params）に直したもの。CR は AuteDev の CR を作る役（Ubuntu4 の Qwen-next-flash）が作った。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値を落とさず写しているか。依頼の中心の条件（× を付けた手で 15 ms・強さ 0.4、宇宙人は 30 ms のまま、× を消す手・宇宙人を取る手では振動しない、スワイプは 1 回だけ）を確かめる項目が無ければ NG。
2. CR の変えること（vibrate に amplitude の引数を足す、vibration_amplitudes の記録、mark の手で vibrate(15, 0.4)）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。
3. 「変わる既存のテスト」（test_cr_1177::test_main_vibrates_on_place_not_mark の tap(3, 3) の後の [30] が [30, 15] に変わる）が CR に写っているか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1180-r0p）のファイル results/cr1180_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。

## 依頼（req_cr1180.txt）

× を付けたときも、宇宙人を置いたとき（30 ミリ秒）より小さく短く振動させて（ユーザーの Pixel の確かめ 10/26 22:5x「ｘをつけた時も、より小さく短く振動させたい。」）。
「× を付けた手」は、Sound.sfx_for が "mark" を返す手（タップで × を付けた手、スワイプで × を 1 つ以上付けた手。スワイプは 1 手で 1 回だけ振動）。× を消す手・宇宙人を取る手では振動しない。チュートリアルの盤の手も同じに振動する（宇宙人を置いたときの振動と同じ扱い）。
「小さく」は Input.vibrate_handheld(duration_ms, amplitude) の 2 つ目の引数 amplitude（0〜1 の強さ。-1.0 は端末の決まりの強さ）で弱める。× の手は 15 ミリ秒・強さ 0.4。宇宙人を置いた手の 30 ミリ秒は強さを渡さない（-1.0）。
- scenes/sound.gd に var vibration_amplitudes: Array = [] を足し、func vibrate(ms: int) を func vibrate(ms: int, amplitude: float = -1.0) -> void に替える。vibrate は vibrations に ms を、vibration_amplitudes に amplitude を足してから Input.vibrate_handheld(ms, amplitude) を呼ぶ。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "mark" なら sound.vibrate(15, 0.4) を呼ぶ。
- Sound.sfx_for、効果音の鳴らし方、宇宙人を置いたときの sound.vibrate(30)、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) する。s.vibrate(30) をしてから s.vibrate(15, 0.4) をしたあとの s.vibrations は [30, 15]、s.vibration_amplitudes は [-1.0, 0.4]（強さを渡さないときは -1.0 を記録する）。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]、m.sound.vibration_amplitudes は [-1.0]。続けて m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [15]。続けて m.session.tap(3, 3) をしたあと（× を消した。消す手では振動しない）の m.sound.vibrations は [15]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [15, 30]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [15, 30]。続けて m.session.tap(3, 3) をしたあと（再び × を付けた）の m.sound.vibrations は [15, 30, 15]、m.sound.vibration_amplitudes は [0.4, -1.0, 0.4]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]) をしたあと（1 回のスワイプで × を 3 つ付けた。1 手なので振動は 1 回）の m.sound.vibrations は [15]、m.sound.vibration_amplitudes は [0.4]。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.tap(0, 1) をしたあと（チュートリアルの盤に × を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。

変わる既存のテスト:
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — m.session.tap(3, 3) のあとの assert_eq(m.sound.vibrations, [30]) は assert_eq(m.sound.vibrations, [30, 15]) に変わる（× を付けた手でも 15 ミリ秒振動する。関数の名前と「× では振動しない」のコメントは古くなるが、名前は変えない）

変わらない既存のテスト:
- test/cr/test_cr_1177.gd::test_sound_vibrate_records_ms — s.vibrate(30) は amplitude を省いても呼べ、vibrations は [30]
- test/cr/test_cr_1176.gd::test_vibrate_permission_is_true — 振動の許可は変えない
- test/cr/test_cr_1033.gd::test_sfx_for_mark — Sound.sfx_for は変えない
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 効果音は "mark" が鳴る。振動は見ていない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — チュートリアルの × の手も振動するが、見ているのは効果音だけ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — × を付ける手が振動するが、見ているのは吹き出しの文だけ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "ｘをつけた時も、より小さく短く振動させたい。"
  said_at: "2026-10-26 22:5x"
  decision: "D-20261026-0622"
  plan: "スマホの振動（置いたとき・× だけの組ができたとき・× を付けたとき・ぶつかったとき）"
  step: "× を付けたとき 15 ミリ秒・強さ 0.4 で振動し、vibrate に強さを足す（CR 4 つ目）"
title: "× を付けたとき小さく短く振動する"
probe: req_cr1180_probe.gd
decls:
  scenes/sound.gd:
  - "var vibration_amplitudes: Array = []"
changes:
- file: scenes/sound.gd
  func: vibrate
  add_params:
  - {name: amplitude, type: float, default: -1.0}
files:
  edit: [scenes/sound.gd, scenes/main.gd]
  new: []
human:
  - "Pixel で × をタップで付けると、宇宙人を置いたときより弱く短くブルッと振動することを見る。× を消したときは振動しないことを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) する。s.vibrate(30) をしてから s.vibrate(15, 0.4) をしたあとの s.vibrations は [30, 15]、s.vibration_amplitudes は [-1.0, 0.4]（強さを渡さないときは -1.0 を記録する）。'
  target: s.vibrate
  expect:
  - 's.vibrations'
  - 's.vibration_amplitudes'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]、m.sound.vibration_amplitudes は [-1.0]。続けて m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。'
  target: m.session.tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [15]。続けて m.session.tap(3, 3) をしたあと（× を消した。消す手では振動しない）の m.sound.vibrations は [15]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [15, 30]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [15, 30]。続けて m.session.tap(3, 3) をしたあと（再び × を付けた）の m.sound.vibrations は [15, 30, 15]、m.sound.vibration_amplitudes は [0.4, -1.0, 0.4]。'
  target: m.session.tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
- id: R4
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]) をしたあと（1 回のスワイプで × を 3 つ付けた。1 手なので振動は 1 回）の m.sound.vibrations は [15]、m.sound.vibration_amplitudes は [0.4]。'
  target: m.session.swipe
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
- id: R5
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.tap(0, 1) をしたあと（チュートリアルの盤に × を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。'
  target: m.tutorial.session.tap
  expect:
  - 'm.sound.vibrations'
  - 'm.sound.vibration_amplitudes'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, game/tutorial.gd, scenes/board_view.gd]
  other:
  - 'scenes/sound.gd の Sound.sfx_for と play_sfx は変えない'
  - 'scenes/main.gd の宇宙人を置いたときの sound.vibrate(30) は変えない'
changing_tests:
  - 'test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark'
unchanged_tests:
  - 'test/cr/test_cr_1177.gd::test_sound_vibrate_records_ms'
  - 'test/cr/test_cr_1176.gd::test_vibrate_permission_is_true'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_mark'
  - 'test/cr/test_cr_1033.gd::test_main_played_mark_on_tap'
  - 'test/cr/test_cr_1038.gd::test_tutorial_mark_sound'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning'
```


## CR（CR-1180-1180v.local.md）

# CR-1180: ×を付けたときの振動を小さく短くする

## 変えること
- `scenes/sound.gd` に `var vibration_amplitudes: Array = []` を足す。
- `scenes/sound.gd` の `vibrate` に引数 `amplitude: float = -1.0` を足す。
- `scenes/sound.gd` の `vibrate` で、`vibrations` に `ms` を、`vibration_amplitudes` に `amplitude` を追加し、`Input.vibrate_handheld(ms, amplitude)` を呼ぶようにする。
- `scenes/main.gd` の `_refresh` で、`sound.play_sfx(sfx_name)` の直後に、`sfx_name == "mark"` なら `sound.vibrate(15, 0.4)` を呼ぶ処理を足す。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/sound.gd`: `SFX_PLACE`、`SFX_MARK`、`SFX_CLEAR`、`SFX_HINT`、`SFX_WRONG`、`SFX_LEVEL_CLEAR`、`SFX_BUTTON`、`BGM_MAIN`、`BGM_TITLE`、`BGM_STAGE1`、`BGM_STAGE2`、`BGM_STAGE3`、`BGM_STAGE4`、`played`、`music_name`、`sfx_player`、`music_player`、`setup`、`play_music`、`stop_music`、`sfx_for`、`bgm_for_size`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: game/tutorial.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd の Sound.sfx_for と play_sfx は変えない（依頼の欄）
- 依頼の欄: scenes/main.gd の宇宙人を置いたときの sound.vibrate(30) は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/sound.gd` に足す（既存のファイルに足す）
  - `var vibration_amplitudes: Array = []`

## 自動で確かめること
1. テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) する。s.vibrate(30) をしてから s.vibrate(15, 0.4) をしたあとの s.vibrations は [30, 15]、s.vibration_amplitudes は [-1.0, 0.4]（強さを渡さないときは -1.0 を記録する）。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [30]、m.sound.vibration_amplitudes は [-1.0]。続けて m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(3, 3) をしたあと（× を付けた）の m.sound.vibrations は [15]。続けて m.session.tap(3, 3) をしたあと（× を消した。消す手では振動しない）の m.sound.vibrations は [15]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を置いた）の m.sound.vibrations は [15, 30]。続けて m.session.double_tap(0, 0) をしたあと（宇宙人を取った。取る手では振動しない）の m.sound.vibrations は [15, 30]。続けて m.session.tap(3, 3) をしたあと（再び × を付けた）の m.sound.vibrations は [15, 30, 15]、m.sound.vibration_amplitudes は [0.4, -1.0, 0.4]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]) をしたあと（1 回のスワイプで × を 3 つ付けた。1 手なので振動は 1 回）の m.sound.vibrations は [15]、m.sound.vibration_amplitudes は [0.4]。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.double_tap(3, 1) をしたあと（チュートリアルの盤に宇宙人を置いた）の m.sound.vibrations は [30]。続けて m.tutorial.session.tap(0, 1) をしたあと（チュートリアルの盤に × を付けた）の m.sound.vibrations は [30, 15]、m.sound.vibration_amplitudes は [-1.0, 0.4]。
6. 既存のテストがすべて合格する。

## 人が確かめること
- 実機で宇宙人を置いたときの振動と、× を付けたときの振動を比べたとき、× のほうが短く弱いか。
- スワイプで複数のマスに × を付けたとき、振動は 1 回だけか。
- × を消す手や宇宙人を取る手で、振動しないか。

## 変わる既存のテスト
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — m.session.tap(3, 3) のあとの assert_eq(m.sound.vibrations, [30]) は assert_eq(m.sound.vibrations, [30, 15]) に変わる（× を付けた手でも 15 ミリ秒振動する。関数の名前と「× では振動しない」のコメントは古くなるが、名前は変えない）

## 変わらない既存のテスト
- test/cr/test_cr_1177.gd::test_sound_vibrate_records_ms — s.vibrate(30) は amplitude を省いても呼べ、vibrations は [30]
- test/cr/test_cr_1176.gd::test_vibrate_permission_is_true — 振動の許可は変えない
- test/cr/test_cr_1033.gd::test_sfx_for_mark — Sound.sfx_for は変えない
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 効果音は "mark" が鳴る。振動は見ていない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — チュートリアルの × の手も振動するが、見ているのは効果音だけ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — × を付ける手が振動するが、見ているのは吹き出しの文だけ

## 対象の候補
- edit: `scenes/sound.gd`、`scenes/main.gd`
