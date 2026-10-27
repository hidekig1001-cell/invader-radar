# クラウドへの依頼: InvaderRadar改修1193 の R0'（CR.md を読む）（1 回目、2026-10-27 21:xx、Invader Radar31）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 8111de3（v2.00-cr1192）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、クラウドが下書きした draft/next-c の drafts/req_rock_ng_both.txt（probe の名前だけ手元の req_cr1193_probe.gd に替え、decision を D-20261027-2103 にした）。岩（数字付き・数字の無い）をタップ・ダブルタップしたら、まちがいのときの NG の音（"wrong"）と振動（250 ms・0.3）を 1 回出す。盤・手数・元に戻すは変えない。なぞりでは鳴らさない。ユーザーの判断 D-20261027-2103＝A（数字の無い岩も同じ）。CR は AuteDev の CR を作る役が作った。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。依頼の箇条が「結果の言い直し」に読まれて CR から落ちることもある（1192）。決まり（音と振動は今の wrong と同じ値、ダブルタップは 1 回目のタップで 1 回だけ鳴る、なぞり・チュートリアルでは鳴らない、盤・手数・元に戻すの記録・Session は変えない、振動の長さと強さは変えない）が、CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値（played・vibrations の値まるごと、手数・盤が変わらない）を落とさず写しているか。依頼の中心の条件（数字付きの岩・数字の無い岩の両方で鳴る、ダブルタップで 1 回だけ、なぞりで鳴らない、ふつうのマスでは鳴らない）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/main.gd の rock_ng と入力の所）が依頼と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。新しい宣言（rock_ng）が依頼の decls と合うか。
3. 変わる既存のテスト・変わらない既存のテストが CR に写っているか。名前が main 8111de3 に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1193-r0p）のファイル results/cr1193_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1193.txt）

岩のマス（数字付きの岩・数字の無い岩）をタップ・ダブルタップしたら、NG の音と振動を出して（ユーザーの指示 10/27 21:0x「１　OK　２　OK　→追加依頼、１，２に該当する場合に、NG音と振動を入れたい」。1 は「数字付きの岩をタップしても × が付かない」、2 は「ダブルタップしても宇宙人が付かない」。数字の無い岩も同じにする、決め D-20261027-2103＝A）。
今は Session.tap・double_tap が岩のマスを弾き、何も付けず手数も増やさないので、音も振動も出ない。
- scenes/main.gd に func rock_ng(x: int, y: int) -> bool を足す。チュートリアル中（is_tutorial()）か session が null なら false。session.is_radar(x, y) か session.is_asteroid(x, y) なら sound.play_sfx("wrong") と sound.vibrate(250, 0.3) を 1 回ずつして true、ほかのマスは何もせず false。盤・手数・元に戻すの記録は変えない。
- scenes/main.gd の func _on_touch_up の "tap" の所の、チュートリアルでないときの session.tap(c.x, c.y) の前で rock_ng(c.x, c.y) を呼ぶ。"double_tap" と "swipe" の所では呼ばない（ダブルタップは 1 回目のタップで鳴るので、鳴るのは 1 回だけ。なぞりは鳴らさない）。
- Session の tap・double_tap・swipe・is_radar・is_asteroid、wrong の音の名前と振動の長さ・強さ、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m.rock_ng(0, 0) は true、そのあとの m.sound.played は ["wrong"]、m.sound.vibrations は [250]。続けて m.rock_ng(3, 3) は true、m.sound.played は ["wrong", "wrong"]、m.sound.vibrations は [250, 250]。続けて m.rock_ng(1, 0) は false（岩でないマス）、m.sound.played は ["wrong", "wrong"]。m.session.board.state_at(0, 0) と m.session.board.state_at(3, 3) は 0、m.session.moves は 0。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあと（数字付きの岩をタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]、m.session.board.state_at(0, 0) は 0、m.session.moves は 0。続けて m._on_touch_down(p(1, 0))・m._on_touch_up(p(1, 0)) をしたあと（岩でないマスをタップ）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(3, 3))・m._on_touch_up(p(3, 3)) を 2 回すぐに続けてしたあと（数字の無い岩をダブルタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]（1 回だけ）、m.session.board.state_at(3, 3) は 0、m.session.moves は 0。
4. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあとの m.sound.played は ["wrong"]。続けて m._on_touch_down(p(0, 1)) をし、index 0 の InputEventScreenDrag を位置 p(0, 0)、p(1, 0) で順に m._input に渡して、m._on_touch_up(p(1, 0)) をしたあと（(0, 1) から岩の (0, 0) を通って (1, 0) までなぞる）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]、m.session.board.state_at(0, 0) は 0、m.session.board.state_at(0, 1) は 1、m.session.board.state_at(1, 0) は 1。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1186.gd::test_is_radar — Session.is_radar は変えない
- test/cr/test_cr_1186.gd::test_tap_and_double_tap_on_radar — Session.tap・double_tap を直接呼び、main の入力を通らないので、音と振動は出ない。盤と手数の決まりは変えない
- test/cr/test_cr_1186.gd::test_swipe_on_radar — なぞりでは rock_ng を呼ばない。Session.swipe は変えない
- test/cr/test_cr_1020.gd::test_is_asteroid — Session.is_asteroid は変えない
- test/cr/test_cr_1020.gd::test_tap_on_asteroid — Session.tap を直接呼び、main の入力を通らない
- test/cr/test_cr_1020.gd::test_double_tap_on_asteroid — Session.double_tap を直接呼び、main の入力を通らない
- test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — Sound.sfx_for の wrong は変えない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — wrong の音と振動の決まり（_refresh）は変えない
- test/cr/test_cr_1043.gd::test_touch_down_up_marks_correct_cell — 岩の無い面のタップで、rock_ng は false
- test/cr/test_cr_1043.gd::test_double_tap_places_piece — 岩の無い面のダブルタップで、rock_ng は false
- test/cr/test_cr_1043.gd::test_drag_stroke_marks_cells — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1043.gd::test_is_on_board_false_outside — 盤の外のタップの決まりは変えない
- test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates — チュートリアル中は rock_ng を呼ばない
- test/unit/test_main_scene.gd::test_touch_gestures_reach_session — 岩でないマスのタップ・ダブルタップ・なぞりで、rock_ng は false
- test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1083.gd::test_cr_1083_check_1 — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1083.gd::test_cr_1083_check_2 — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1051.gd::test_cr1051_3_save_on_next_level — クリアの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1100.gd::test_cr1100_1_last_level_clear_and_title — クリアの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1188.gd::test_cr_1188_main_integration — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "１　OK　２　OK　→追加依頼、１，２に該当する場合に、NG音と振動を入れたい"
  said_at: "2026-10-27 21:0x"
  decision: "D-20261027-2103"
  plan: "Pixel の確かめで出た追加の依頼（C 組）"
  step: "岩のタップ・ダブルタップで NG の音と振動（C 組の 1 本目、数字の無い岩も同じ）"
title: "岩をタップしたら NG の音と振動"
probe: req_cr1193_probe.gd
decls:
  scenes/main.gd:
  - "func rock_ng(x: int, y: int) -> bool"
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel で、数字付きの岩と数字の無い岩をタップ・ダブルタップして、NG の音と振動が 1 回ずつ出ること、なぞりでは鳴らないことを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m.rock_ng(0, 0) は true、そのあとの m.sound.played は ["wrong"]、m.sound.vibrations は [250]。続けて m.rock_ng(3, 3) は true、m.sound.played は ["wrong", "wrong"]、m.sound.vibrations は [250, 250]。続けて m.rock_ng(1, 0) は false（岩でないマス）、m.sound.played は ["wrong", "wrong"]。m.session.board.state_at(0, 0) と m.session.board.state_at(3, 3) は 0、m.session.moves は 0。'
  target: m.rock_ng
  expect:
  - 'm.rock_ng(0, 0)'
  - 'm.sound.played'
  - 'm.sound.vibrations'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあと（数字付きの岩をタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]、m.session.board.state_at(0, 0) は 0、m.session.moves は 0。続けて m._on_touch_down(p(1, 0))・m._on_touch_up(p(1, 0)) をしたあと（岩でないマスをタップ）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]。'
  target: m._on_touch_up
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
  - 'm.session.moves'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(3, 3))・m._on_touch_up(p(3, 3)) を 2 回すぐに続けてしたあと（数字の無い岩をダブルタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]（1 回だけ）、m.session.board.state_at(3, 3) は 0、m.session.moves は 0。'
  target: m._on_touch_up
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
  - 'm.session.moves'
- id: R4
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあとの m.sound.played は ["wrong"]。続けて m._on_touch_down(p(0, 1)) をし、index 0 の InputEventScreenDrag を位置 p(0, 0)、p(1, 0) で順に m._input に渡して、m._on_touch_up(p(1, 0)) をしたあと（(0, 1) から岩の (0, 0) を通って (1, 0) までなぞる）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]、m.session.board.state_at(0, 0) は 0、m.session.board.state_at(0, 1) は 1、m.session.board.state_at(1, 0) は 1。'
  target: m._on_touch_up
  expect:
  - 'm.sound.played'
  - 'm.sound.vibrations'
  - 'm.session.board.state_at'
extra_items: 0
keep:
  files: [game/session.gd, scenes/sound.gd, scenes/input_mapper.gd, scenes/board_view.gd]
  other:
  - 'Session の tap・double_tap・swipe・is_radar・is_asteroid は変えない'
  - 'wrong の振動の長さ 250・強さ 0.3 は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1186.gd::test_is_radar'
  - 'test/cr/test_cr_1186.gd::test_tap_and_double_tap_on_radar'
  - 'test/cr/test_cr_1186.gd::test_swipe_on_radar'
  - 'test/cr/test_cr_1020.gd::test_is_asteroid'
  - 'test/cr/test_cr_1020.gd::test_tap_on_asteroid'
  - 'test/cr/test_cr_1020.gd::test_double_tap_on_asteroid'
  - 'test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only'
  - 'test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_wrong'
  - 'test/cr/test_cr_1038.gd::test_tutorial_wrong_sound'
  - 'test/cr/test_cr_1043.gd::test_touch_down_up_marks_correct_cell'
  - 'test/cr/test_cr_1043.gd::test_double_tap_places_piece'
  - 'test/cr/test_cr_1043.gd::test_drag_stroke_marks_cells'
  - 'test/cr/test_cr_1043.gd::test_is_on_board_false_outside'
  - 'test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates'
  - 'test/unit/test_main_scene.gd::test_touch_gestures_reach_session'
  - 'test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board'
  - 'test/cr/test_cr_1083.gd::test_cr_1083_check_1'
  - 'test/cr/test_cr_1083.gd::test_cr_1083_check_2'
  - 'test/cr/test_cr_1051.gd::test_cr1051_3_save_on_next_level'
  - 'test/cr/test_cr_1100.gd::test_cr1100_1_last_level_clear_and_title'
  - 'test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja'
  - 'test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age'
  - 'test/cr/test_cr_1188.gd::test_cr_1188_main_integration'
```

## CR（CR-1193-1193v.local.md）

# CR-1193: 岩をタップしたら NG の音と振動

## 変えること
- scenes/main.gd に func rock_ng(x: int, y: int) -> bool を足す。チュートリアル中（is_tutorial()）か session が null なら false。session.is_radar(x, y) か session.is_asteroid(x, y) なら sound.play_sfx("wrong") と sound.vibrate(250, 0.3) を 1 回ずつして true、ほかのマスは何もせず false。盤・手数・元に戻すの記録は変えない。
- scenes/main.gd の func _on_touch_up の "tap" の所の、チュートリアルでないときの session.tap(c.x, c.y) の前で rock_ng(c.x, c.y) を呼ぶ。"double_tap" と "swipe" の所では呼ばない（ダブルタップは 1 回目のタップで鳴るので、鳴るのは 1 回だけ。なぞりは鳴らさない）。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`last_dead`、`last_dead_marks`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/input_mapper.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: Session の tap・double_tap・swipe・is_radar・is_asteroid は変えない（依頼の欄）
- 依頼の欄: wrong の振動の長さ 250・強さ 0.3 は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/main.gd` に足す（既存のファイルに足す）
  - `func rock_ng(x: int, y: int) -> bool`

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m.rock_ng(0, 0) は true、そのあとの m.sound.played は ["wrong"]、m.sound.vibrations は [250]。続けて m.rock_ng(3, 3) は true、m.sound.played は ["wrong", "wrong"]、m.sound.vibrations は [250, 250]。続けて m.rock_ng(1, 0) は false（岩でないマス）、m.sound.played は ["wrong", "wrong"]。m.session.board.state_at(0, 0) と m.session.board.state_at(3, 3) は 0、m.session.moves は 0。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあと（数字付きの岩をタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]、m.session.board.state_at(0, 0) は 0、m.session.moves は 0。続けて m._on_touch_down(p(1, 0))・m._on_touch_up(p(1, 0)) をしたあと（岩でないマスをタップ）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(3, 3))・m._on_touch_up(p(3, 3)) を 2 回すぐに続けてしたあと（数字の無い岩をダブルタップ）の m.sound.played は ["wrong"]、m.sound.vibrations は [250]（1 回だけ）、m.session.board.state_at(3, 3) は 0、m.session.moves は 0。
4. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "radar": [[0, 0, 1]], "asteroids": [[3, 3]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする（始めの m.sound.played と m.sound.vibrations は []）。マス (x, y) の画面の位置 p(x, y) は m.board_view.global_position + m.board_view.cell_rect(x, y).get_center() とする。m._on_touch_down(p(0, 0))・m._on_touch_up(p(0, 0)) をしたあとの m.sound.played は ["wrong"]。続けて m._on_touch_down(p(0, 1)) をし、index 0 の InputEventScreenDrag を位置 p(0, 0)、p(1, 0) で順に m._input に渡して、m._on_touch_up(p(1, 0)) をしたあと（(0, 1) から岩の (0, 0) を通って (1, 0) までなぞる）の m.sound.played は ["wrong", "mark"]、m.sound.vibrations は [250, 15]、m.session.board.state_at(0, 0) は 0、m.session.board.state_at(0, 1) は 1、m.session.board.state_at(1, 0) は 1。
5. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で、数字付きの岩と数字の無い岩をタップ・ダブルタップして、NG の音と振動が 1 回ずつ出ること、なぞりでは鳴らないことを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1186.gd::test_is_radar — Session.is_radar は変えない
- test/cr/test_cr_1186.gd::test_tap_and_double_tap_on_radar — Session.tap・double_tap を直接呼び、main の入力を通らないので、音と振動は出ない。盤と手数の決まりは変えない
- test/cr/test_cr_1186.gd::test_swipe_on_radar — なぞりでは rock_ng を呼ばない。Session.swipe は変えない
- test/cr/test_cr_1020.gd::test_is_asteroid — Session.is_asteroid は変えない
- test/cr/test_cr_1020.gd::test_tap_on_asteroid — Session.tap を直接呼び、main の入力を通らない
- test/cr/test_cr_1020.gd::test_double_tap_on_asteroid — Session.double_tap を直接呼び、main の入力を通らない
- test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — Sound.sfx_for の wrong は変えない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — wrong の音と振動の決まり（_refresh）は変えない
- test/cr/test_cr_1043.gd::test_touch_down_up_marks_correct_cell — 岩の無い面のタップで、rock_ng は false
- test/cr/test_cr_1043.gd::test_double_tap_places_piece — 岩の無い面のダブルタップで、rock_ng は false
- test/cr/test_cr_1043.gd::test_drag_stroke_marks_cells — なぞりでは rock_ng を呼ばない
- test/cr/test_cr_1043.gd::test_is_on_board_false_outside — 盤の外のタップの決まりは変えない
- test/cr/test_cr_1043.gd::test_tutorial_input_transforms_coordinates — チュートリアル中は rock_ng を呼ばない
- test/unit/test_main_scene.gd::test_touch_gestures_reach_session — 岩でないマスのタップ・ダブルタップ・なぞりで、rock_ng は false
- test/cr/test_cr_1012.gd::test_tutorial_input_next_via_touch_outside_board — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1083.gd::test_cr_1083_check_1 — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1083.gd::test_cr_1083_check_2 — チュートリアル中は rock_ng を呼ばない
- test/cr/test_cr_1051.gd::test_cr1051_3_save_on_next_level — クリアの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1100.gd::test_cr1100_1_last_level_clear_and_title — クリアの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る
- test/cr/test_cr_1188.gd::test_cr_1188_main_integration — お知らせの札を消すタッチは、盤のマスのタップに届く前に返る

## 対象の候補
- edit: `scenes/main.gd`
