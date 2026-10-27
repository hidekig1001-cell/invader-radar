# クラウドへの依頼: InvaderRadar改修1189 の R0'（CR.md を読む）（1 回目、2026-10-27 18:5x、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 46fc619（v1.97-cr1188）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きした draft/next-b の drafts/req_quiet_first_refresh.txt（probe の名前だけ手元の req_cr1189_probe.gd に替えた）。立ち上げ・読み直しの最初の _refresh で効果音と振動を出さない（last_snapshot が空なら sfx_name を "" にする）。CR は AuteDev の CR を作る役（機械の経路）が作った。
手元の当て試し（main 46fc619 の写し）では、直しを当てると落ちたのは「変わる既存のテスト」の test_cr_1179_main_dead_initial_state の 1 件だけ、直しなしでは probe の 3 件だけが落ちた。依頼の検査は error 0。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（sfx_for の後で last_snapshot.is_empty() なら sfx_name = ""、last_snapshot などの入れ直し・dead と line の決まり・2 回目からの音と振動・振動の長さと強さ・チュートリアル・sound.gd の sfx_for は変えない）が、CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜3 の手順と期待値（立ち上げ直後の played・vibrations が []、そのあとの手で ["mark"]・[15]、["dead"]・[250]）を落とさず写しているか。依頼の中心の条件（盤に宇宙人・×・ぶつかり・× だけの組があっても最初の _refresh は鳴らさず震えない、2 回目からは今までどおり）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/main.gd の _refresh の 1 か所）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。
3. 「変わる既存のテスト」の test_cr_1179_main_dead_initial_state の 2 か所（[15]→[]、[15, 250]→[250]、ほかの表明は変えない）と、「変わらない既存のテスト」の 41 個が CR に写っているか。名前が main 46fc619 に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1189-r0p）のファイル results/cr1189_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1189.txt）

立ち上げたとき・進み具合を読み直したとき（main の最初の _refresh）に、効果音と振動を出さないようにして（引き継ぎの候補: ぶつかった盤を読み直すと最初に 250 ミリ秒、× のある盤で 15 ミリ秒の振動が出る）。今は最初の _refresh で last_snapshot が空 {} なので、Sound.sfx_for が盤の宇宙人・×・ぶつかりを「この手で増えた」と読み、宇宙人がある盤では place（30 ミリ秒）、× だけの盤では mark（15 ミリ秒・0.4）、ぶつかった宇宙人がある盤では wrong（250 ミリ秒・0.3）を鳴らして振動する。line と dead への差し替えは、今も last_snapshot が空なら起きない。

- scenes/main.gd の func _refresh で、Sound.sfx_for(last_snapshot, curr_snapshot, last_conflicts, curr_conflicts) で sfx_name を決めたすぐあとに、last_snapshot.is_empty() が true なら sfx_name を "" にする（最初の _refresh では効果音も振動も line の光も出さない）。
- last_snapshot・last_conflicts・last_dead_marks・last_lines の入れ直し、dead と line に替える決まり、2 回目からの _refresh の効果音と振動、チュートリアル、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 2, 0) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（宇宙人 1 つと × 2 つの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(3, 1) をしたあと（2 回目からは今までどおり鳴る）の m.sound.played は ["mark"]、m.sound.vibrations は [15]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("place", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（斜め隣の 2 つの宇宙人がぶつかった盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（区域 0 が × だけの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して付け直し、区域 0 が再び × だけになった）の m.sound.played は ["dead"]、m.sound.vibrations は [250]。

変わる既存のテスト:
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 立ち上げたあとの assert_eq(m.sound.vibrations, [15]) は assert_eq(m.sound.vibrations, []) に、m.session.tap(1, 1)・m.session.tap(1, 1) のあとの assert_eq(m.sound.vibrations, [15, 250]) は assert_eq(m.sound.vibrations, [250]) に変わる（最初の _refresh で mark の 15 が出なくなる。ほかの表明は変えない）

変わらない既存のテスト:
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_on_initial_load_with_lines — 見ているのは line の数だけ。立ち上げの place が鳴らなくなっても line の数は 0 のまま
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_completion_before_clear — 盤を置いてから立ち上げるが、見ているのは手のあとの played[-1]・line の数・status だけ
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 空の盤で立ち上げるので最初の _refresh は今も何も鳴らない
- test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title — button は _refresh を通らない
- test/cr/test_cr_1033.gd::test_main_music_setup — 曲は play_music で、効果音ではない
- test/cr/test_cr_1140.gd::test_update_music_changes_bgm — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — チュートリアルは start_tutorial で last_snapshot を入れるので、最初の _refresh ではない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — last_snapshot・last_conflicts の入れ方は変えない
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — 空の盤で立ち上げる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — 空の盤で立ち上げる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 同じ。面の切り替えは最初の _refresh ではない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_place_and_mark — 空の盤で立ち上げる
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_sequence — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_swipe — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_diagonal_collision_vibration — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_vertical_collision_and_removal_vibration — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_place_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_mark_completion_and_new_region — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_retrigger_on_mark_toggle — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_and_mark_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 同じ
- test/cr/test_cr_1185.gd::test_main_flash_on_line_completion — 同じ
- test/cr/test_cr_1185.gd::test_main_flash_multiple_lines_order_and_unique_cells — 盤を置いてから立ち上げるが、最初の _refresh は今も last_snapshot が空なので line にならず光らない。見ているのは手のあとの flashes だけ
- test/cr/test_cr_1185.gd::test_main_no_flash_on_dead_line_then_flash_on_region — 空の盤で立ち上げる
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — 同じ
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — 同じ
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 同じ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: '（引き継ぎの候補）ぶつかった盤を読み直すと最初に 250 ms、× のある盤で 15 ms が出る'
  said_at: "2026-10-27 18:2x"
  decision: "未定（ユーザーの判断の後に入れる）"
  plan: "不具合の芽を先に直す（B 組）"
  step: "立ち上げの最初の _refresh で音と振動を出さない"
title: "立ち上げの最初の _refresh で音と振動を出さない"
probe: req_cr1189_probe.gd
decls: {}
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel で、宇宙人や × やぶつかった宇宙人がある進み具合から続きを始めたとき、立ち上がった瞬間に効果音も振動も出ないことを見る。そのあとの手では今までどおり鳴って震えることを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 2, 0) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（宇宙人 1 つと × 2 つの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(3, 1) をしたあと（2 回目からは今までどおり鳴る）の m.sound.played は ["mark"]、m.sound.vibrations は [15]。'
  target: m.session.tap
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("place", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（斜め隣の 2 つの宇宙人がぶつかった盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。'
  target: m.session
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（区域 0 が × だけの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して付け直し、区域 0 が再び × だけになった）の m.sound.played は ["dead"]、m.sound.vibrations は [250]。'
  target: m.session.tap
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
extra_items: 0
keep:
  files: [scenes/sound.gd, core/rules.gd, game/session.gd, scenes/board_view.gd]
  other:
  - 'scenes/sound.gd の Sound.sfx_for は変えない'
  - 'scenes/main.gd の dead と line に替える決まりと、振動の長さと強さは変えない'
changing_tests:
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state'
unchanged_tests:
  - 'test/cr/test_cr_1184.gd::test_cr_1184_no_line_on_initial_load_with_lines'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_on_completion_before_clear'
  - 'test/cr/test_cr_1033.gd::test_main_played_mark_on_tap'
  - 'test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title'
  - 'test/cr/test_cr_1033.gd::test_main_music_setup'
  - 'test/cr/test_cr_1140.gd::test_update_music_changes_bgm'
  - 'test/cr/test_cr_1038.gd::test_tutorial_place_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_mark_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_wrong_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_init_last_values'
  - 'test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_place_and_mark'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_sequence'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_swipe'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition'
  - 'test/cr/test_cr_1181.gd::test_cr_1181_diagonal_collision_vibration'
  - 'test/cr/test_cr_1181.gd::test_cr_1181_vertical_collision_and_removal_vibration'
  - 'test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_on_place_completion'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_on_mark_completion_and_new_region'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_retrigger_on_mark_toggle'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_completion'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_and_mark_completion'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line'
  - 'test/cr/test_cr_1185.gd::test_main_flash_on_line_completion'
  - 'test/cr/test_cr_1185.gd::test_main_flash_multiple_lines_order_and_unique_cells'
  - 'test/cr/test_cr_1185.gd::test_main_no_flash_on_dead_line_then_flash_on_region'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line'
  - 'test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group'
```

## CR（CR-1189-1189v.local.md）

# CR-1189: 立ち上げの最初の _refresh で音と振動を出さない

## 変えること
- scenes/main.gd の func _refresh で、Sound.sfx_for(last_snapshot, curr_snapshot, last_conflicts, curr_conflicts) で sfx_name を決めたすぐあとに、last_snapshot.is_empty() が true なら sfx_name を "" にする（最初の _refresh では効果音も振動も line の光も出さない）。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_dead`、`last_dead_marks`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd の Sound.sfx_for は変えない（依頼の欄）
- 依頼の欄: scenes/main.gd の dead と line に替える決まりと、振動の長さと強さは変えない（依頼の欄）

## 新しい宣言
なし

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 2, 0) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（宇宙人 1 つと × 2 つの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(3, 1) をしたあと（2 回目からは今までどおり鳴る）の m.sound.played は ["mark"]、m.sound.vibrations は [15]。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("place", 0, 0)、m.session.board.apply("place", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（斜め隣の 2 つの宇宙人がぶつかった盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd")、var Main = load("res://scenes/main.tscn") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = Main.instantiate() として m.session = SessionScript.new([level]) とする。add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（読み直した進み具合と同じ形の盤から始める）。add_child_autofree(m) をして await wait_frames(2) をする。そのあと（区域 0 が × だけの盤で立ち上げた）の m.sound.played は []、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して付け直し、区域 0 が再び × だけになった）の m.sound.played は ["dead"]、m.sound.vibrations は [250]。
4. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で、宇宙人や × やぶつかった宇宙人がある進み具合から続きを始めたとき、立ち上がった瞬間に効果音も振動も出ないことを見る。そのあとの手では今までどおり鳴って震えることを見る。

## 変わる既存のテスト
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 立ち上げたあとの assert_eq(m.sound.vibrations, [15]) は assert_eq(m.sound.vibrations, []) に、m.session.tap(1, 1)・m.session.tap(1, 1) のあとの assert_eq(m.sound.vibrations, [15, 250]) は assert_eq(m.sound.vibrations, [250]) に変わる（最初の _refresh で mark の 15 が出なくなる。ほかの表明は変えない）

## 変わらない既存のテスト
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_on_initial_load_with_lines — 見ているのは line の数だけ。立ち上げの place が鳴らなくなっても line の数は 0 のまま
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_completion_before_clear — 盤を置いてから立ち上げるが、見ているのは手のあとの played[-1]・line の数・status だけ
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 空の盤で立ち上げるので最初の _refresh は今も何も鳴らない
- test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title — button は _refresh を通らない
- test/cr/test_cr_1033.gd::test_main_music_setup — 曲は play_music で、効果音ではない
- test/cr/test_cr_1140.gd::test_update_music_changes_bgm — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — チュートリアルは start_tutorial で last_snapshot を入れるので、最初の _refresh ではない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — 同じ
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — last_snapshot・last_conflicts の入れ方は変えない
- test/cr/test_cr_1177.gd::test_main_vibrates_on_place_not_mark — 空の盤で立ち上げる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — 空の盤で立ち上げる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 同じ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 同じ。面の切り替えは最初の _refresh ではない
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_place_and_mark — 空の盤で立ち上げる
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_sequence — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_swipe — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_in_tutorial — 同じ
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_diagonal_collision_vibration — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_vertical_collision_and_removal_vibration — 同じ
- test/cr/test_cr_1181.gd::test_cr_1181_tutorial_collision_vibration — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_place_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_mark_completion_and_new_region — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_retrigger_on_mark_toggle — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_line_on_alien_removal_and_mark_completion — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_no_line_in_tutorial — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 同じ
- test/cr/test_cr_1185.gd::test_main_flash_on_line_completion — 同じ
- test/cr/test_cr_1185.gd::test_main_flash_multiple_lines_order_and_unique_cells — 盤を置いてから立ち上げるが、最初の _refresh は今も last_snapshot が空なので line にならず光らない。見ているのは手のあとの flashes だけ
- test/cr/test_cr_1185.gd::test_main_no_flash_on_dead_line_then_flash_on_region — 空の盤で立ち上げる
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_region — 同じ
- test/cr/test_cr_1187.gd::test_cr_1187_new_dead_group_line — 同じ
- test/cr/test_cr_1187.gd::test_cr_1187_undo_dead_group — 同じ

## 対象の候補
- edit: `scenes/main.gd`
