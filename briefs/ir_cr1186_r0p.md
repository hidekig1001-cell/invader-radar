# クラウドへの依頼: InvaderRadar改修1186 の R0'（CR.md を読む）（1 回目、2026-10-27 16:2x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 0ae3435（v1.94-cr1185）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きした draft/bug-dead-radar の drafts/req_bug_radar_block.txt（probe の名前だけ手元の req_cr1186_probe.gd に替えた）。数字付きの岩（レーダー）に × も宇宙人も付けられないようにする（岩A）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。
手元の当て試し（main 0ae3435 の写し）では、直しを当てると 741 件すべて通り、直しなしでは probe の 3 件だけが落ちた（is_radar が無い）。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まりが CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値を落とさず写しているか。依頼の中心の条件（is_radar がレーダーのマスで true・ほかで false、tap・double_tap・swipe でレーダーのマスが変わらず false を返す、小惑星と普通のマスの扱いは今のまま）を確かめる項目が無ければ NG。
2. CR の変えること（game/session.gd の is_radar と、tap・double_tap・swipe で弾く所）が依頼と合っているか。依頼に無い箇条・余計な変更（board_view・rules・main を変えるなど）・抜けが無いか。
3. 「変わる既存のテスト」「変わらない既存のテスト」が依頼どおり CR に写っているか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1186-r0p）のファイル results/cr1186_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1186.txt）

数字付きの岩（レーダーのマス）に宇宙人を置けないようにして（ユーザーの Pixel の確かめ 10/27 16:0x「左下の数字付きの岩にインベーダーをおけてしまう」。レベル 6 の (0, 4) の数字 1 の岩）。今は数字の無い岩（小惑星、level.asteroids）だけを Session.is_asteroid で弾いていて、数字付きの岩（level.radar）は CR-1171 で岩の絵を敷いただけなので、タップ・ダブルタップ・スワイプで × も宇宙人も付いてしまう。数字付きの岩は、数字の無い岩と同じく、× も宇宙人も付けられないマスにする（盤の決まりでは、レーダーのマスの宇宙人は Rules.conflicts で赤くなり、レーダーのマスの × は Rules.dead_marks・Rules.filled_lines で数えないので、付けられて得なことは無い）。

- game/session.gd に func is_radar(x: int, y: int) -> bool を足す。level が null なら false、level.radar の [x, y, n] のどれかの x・y が同じなら true、ほかは false を返す。
- game/session.gd の func tap と func double_tap の最初の判定（is_asteroid(x, y) か is_given(x, y) なら false を返す所）に is_radar(x, y) を足し、数字付きの岩のマスでは盤を変えずに false を返す（手数も増えない）。
- game/session.gd の func swipe で、なぞったマスから除くマス（小惑星と最初から置いてある宇宙人）に is_radar(c.x, c.y) のマスも足す。除いたあとに空のマスが無ければ今と同じく false を返す。
- Session.is_asteroid、Rules の関数、ヒント（Hint・apply_hint）、盤の絵（scenes/board_view.gd）、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.is_radar(0, 0) は true、s.is_radar(1, 0) は false、s.is_radar(3, 3) は false（数字の無い岩はレーダーではない）。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.tap(0, 0) の戻り値は false、続けて s.double_tap(0, 0) の戻り値は false、そのあとの s.board.state_at(0, 0) は 0（空のまま）、s.moves は 0。続けて s.tap(1, 0) の戻り値は true、そのあとの s.board.state_at(1, 0) は 1（×）、s.moves は 1（ほかのマスは今までどおり）。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.swipe([Vector2i(0, 0)]) の戻り値は false、そのあとの s.moves は 0。続けて s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]) の戻り値は true、そのあとの s.board.state_at(0, 0) は 0、s.board.state_at(1, 0) は 1、s.board.state_at(2, 0) は 1、s.moves は 1。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1020.gd::test_is_asteroid — Session.is_asteroid は変えない
- test/cr/test_cr_1020.gd::test_tap_on_asteroid — 小惑星の扱いは変えない（この面にレーダーは無い）
- test/cr/test_cr_1020.gd::test_double_tap_on_asteroid — 同じ
- test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only — 同じ
- test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty — 同じ
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session — レーダーのマスの × は board.apply で直に付けるので、Session.tap の判定を通らない
- test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color — 同じ
- test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece — レーダーのマスの宇宙人と × は board.apply で直に付ける
- test/cr/test_cr_1048.gd::test_radar_text_color_exceeded — board.apply で直に置く
- test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded — Rules.filled_lines は変えない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: 'また、左下の数字付きの岩にインベーダーをおけてしまう。'
  said_at: "2026-10-27 16:0x"
  decision: "未定（ユーザーの判断の後に入れる）"
  plan: "Pixel の確かめ（0ae3435）の指摘を直す"
  step: "数字付きの岩に × も宇宙人も付けられないようにする"
title: "数字付きの岩に × も宇宙人も付けられないようにする"
probe: req_cr1186_probe.gd
decls:
  game/session.gd:
  - "func is_radar(x: int, y: int) -> bool"
files:
  edit: [game/session.gd]
  new: []
human:
  - "Pixel でレベル 6 の左下 (0, 4) の数字 1 の岩をタップ・ダブルタップ・スワイプしても、× も宇宙人も付かず、手数も増えないことを見る。数字の無い岩も今までどおり付かないことを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.is_radar(0, 0) は true、s.is_radar(1, 0) は false、s.is_radar(3, 3) は false（数字の無い岩はレーダーではない）。'
  target: s.is_radar
  expect:
  - 's.is_radar(0, 0)'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.tap(0, 0) の戻り値は false、続けて s.double_tap(0, 0) の戻り値は false、そのあとの s.board.state_at(0, 0) は 0（空のまま）、s.moves は 0。続けて s.tap(1, 0) の戻り値は true、そのあとの s.board.state_at(1, 0) は 1（×）、s.moves は 1（ほかのマスは今までどおり）。'
  target: s.double_tap
  expect:
  - 's.board.state_at(0, 0)'
  - 's.moves'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.swipe([Vector2i(0, 0)]) の戻り値は false、そのあとの s.moves は 0。続けて s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]) の戻り値は true、そのあとの s.board.state_at(0, 0) は 0、s.board.state_at(1, 0) は 1、s.board.state_at(2, 0) は 1、s.moves は 1。'
  target: s.swipe
  expect:
  - 's.board.state_at(0, 0)'
  - 's.moves'
extra_items: 0
keep:
  files: [core/rules.gd, core/hint.gd, scenes/board_view.gd, scenes/main.gd]
  other:
  - 'game/session.gd の is_asteroid と apply_hint は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1020.gd::test_is_asteroid'
  - 'test/cr/test_cr_1020.gd::test_tap_on_asteroid'
  - 'test/cr/test_cr_1020.gd::test_double_tap_on_asteroid'
  - 'test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only'
  - 'test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty'
  - 'test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session'
  - 'test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color'
  - 'test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece'
  - 'test/cr/test_cr_1048.gd::test_radar_text_color_exceeded'
  - 'test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded'
```

## CR（CR-1186-1186v.local.md）

# CR-1186: 数字付きの岩に × も宇宙人も付けられないようにする

## 変えること
- game/session.gd に func is_radar(x: int, y: int) -> bool を足す。level が null なら false、level.radar の [x, y, n] のどれかの x・y が同じなら true、ほかは false を返す。
- game/session.gd の func tap と func double_tap の最初の判定（is_asteroid(x, y) か is_given(x, y) なら false を返す所）に is_radar(x, y) を足し、数字付きの岩のマスでは盤を変えずに false を返す（手数も増えない）。
- game/session.gd の func swipe で、なぞったマスから除くマス（小惑星と最初から置いてある宇宙人）に is_radar(c.x, c.y) のマスも足す。除いたあとに空のマスが無ければ今と同じく false を返す。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/cloud_payload.gd`、`game/level.gd`、`game/level_maker.gd`、`game/level_pack.gd`、`game/level_prefetch.gd`、`game/licenses.gd`、`game/progress_store.gd`、`game/session_save.gd`、`game/sound_settings.gd`、`game/tutorial.gd`、`game/tutorial_steps.gd`、`project.godot`、`scenes/`、`test/`、`tools/`、`.autedev/`
- `game/session.gd`: `changed`、`BoardState`、`Rules`、`LevelPack`、`Hint`、`LevelMaker`、`Solver`、`LevelPrefetch`、`LEVEL_PATHS`、`DEFAULT_HINTS`、`CLEAR_SCORE`、`levels`、`level_index`、`score`、`hints`、`status`、`current_hint`、`rng`、`uses_default_levels`、`given`、`elapsed`、`max_cleared`、`clear_records`、`prefetch`、`placeholder_regions`、`load_default_levels`、`undo`、`use_hint`、`next_level`、`restart_level`、`snapshot`、`request_hint`、`apply_hint`、`save_dict`、`restore_dict`、`solve_now`、`tick`、`prefetch_next`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: core/hint.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd の is_asteroid と apply_hint は変えない（依頼の欄）

## 新しい宣言
- `res://game/session.gd` に足す（既存のファイルに足す）
  - `func is_radar(x: int, y: int) -> bool`

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.is_radar(0, 0) は true、s.is_radar(1, 0) は false、s.is_radar(3, 3) は false（数字の無い岩はレーダーではない）。
2. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.tap(0, 0) の戻り値は false、続けて s.double_tap(0, 0) の戻り値は false、そのあとの s.board.state_at(0, 0) は 0（空のまま）、s.moves は 0。続けて s.tap(1, 0) の戻り値は true、そのあとの s.board.state_at(1, 0) は 1（×）、s.moves は 1（ほかのマスは今までどおり）。
3. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]], "asteroids": [[3, 3]], "radar": [[0, 0, 1]]}) をする（(0, 0) は数字 1 のレーダーの岩、(3, 3) は数字の無い岩（小惑星）。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var s = SessionScript.new([level]) とする。s.swipe([Vector2i(0, 0)]) の戻り値は false、そのあとの s.moves は 0。続けて s.swipe([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]) の戻り値は true、そのあとの s.board.state_at(0, 0) は 0、s.board.state_at(1, 0) は 1、s.board.state_at(2, 0) は 1、s.moves は 1。
4. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel でレベル 6 の左下 (0, 4) の数字 1 の岩をタップ・ダブルタップ・スワイプしても、× も宇宙人も付かず、手数も増えないことを見る。数字の無い岩も今までどおり付かないことを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1020.gd::test_is_asteroid — Session.is_asteroid は変えない
- test/cr/test_cr_1020.gd::test_tap_on_asteroid — 小惑星の扱いは変えない（この面にレーダーは無い）
- test/cr/test_cr_1020.gd::test_double_tap_on_asteroid — 同じ
- test/cr/test_cr_1020.gd::test_swipe_on_asteroid_only — 同じ
- test/cr/test_cr_1020.gd::test_swipe_mixed_asteroid_and_empty — 同じ
- test/cr/test_cr_1130.gd::test_has_radar_and_mark_color_at_with_session — レーダーのマスの × は board.apply で直に付けるので、Session.tap の判定を通らない
- test/cr/test_cr_1137.gd::test_mark_color_at_and_radar_text_color — 同じ
- test/cr/test_pixel_1023.gd::test_pixel_1023_radar_text_white_on_piece — レーダーのマスの宇宙人と × は board.apply で直に付ける
- test/cr/test_cr_1048.gd::test_radar_text_color_exceeded — board.apply で直に置く
- test/cr/test_cr_1183.gd::test_cr_1183_asteroids_and_radar_excluded — Rules.filled_lines は変えない

## 対象の候補
- edit: `game/session.gd`
