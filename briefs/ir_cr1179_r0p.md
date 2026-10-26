# クラウドセッションへの依頼: IR CR-1179 の R0'（CR.md を読む）（2026-10-26 22:2x、Invader Radar改修28）

リポジトリ hidekig1001-cell/invader-radar（private）。読み比べに使う main は 1e08e7f（v1.84-sfx。dead.wav が入った版）。振動の vibrate は CR-1177 の branch cr/1177-safe-apply にある（まだ main に無い）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、cr ブランチでは test/cr/ に入る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値を落とさず写しているか。依頼の中心の条件（× だけの組が空から空でなくなった瞬間だけ dead を鳴らして 120 ms 振動、宇宙人がいる組は数えない、増えたときは鳴らさない、空に戻ってから再び鳴る、チュートリアルと最初の _refresh では鳴らさない）を確かめる項目があるか。無ければ NG。
2. CR の変えること（scenes/sound.gd と scenes/main.gd）が依頼の箇条と合っているか。依頼に無い箇条・余計な変更・抜けが無いか。
3. 変わる／変わらない既存のテストの扱いが依頼と合っているか。main のテスト（sfx_for・play_sfx・played・_refresh・dead_marks を見ているもの）を grep して確かめる。
4. vibrate が main に無い（CR-1177 が先に入る）ことで困る点が CR にあれば書く。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1179-r0p）のファイル results/cr1179_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。
- 最後の返答にも同じ 1 行目を書く。

## 依頼（req_cr1179.txt）

行・列・色（区域）のどれかが × だけで埋まった瞬間に、テンションが下がる効果音 "dead" を鳴らし、スマホを 120 ミリ秒振動させて（ユーザーの Pixel の確かめ 10/26 06:28「5 okだけと音（テンション下がる効果音）のスマホの振動を入れて」。振動の許可は CR-1176、振動の関数 vibrate は CR-1177 で足す）。
「× だけで埋まった瞬間」は、Rules.dead_marks(session.board, session.level) が空の盤から、1 回の手で空でない盤になったとき。すでに空でないときに × だけの組が増えても鳴らさない（例: 区域 0 が × だけのとき、行 0 も × だけになっても鳴らさない）。× を消して空に戻ってから再び空でなくなったら再び鳴らす。宇宙人がいる行・列・区域は × だけの組に数えない（Rules.dead_marks の決まりのとおり）。
効果音の順は level_clear > wrong > hint > clear > place > dead > mark とする（× を付けて × だけの組ができた手は mark ではなく dead を鳴らす）。チュートリアルの間と、main を立ち上げた最初の _refresh では dead を鳴らさない。効果音のファイル dead.wav は別に用意して place.wav と同じフォルダに入れてから流す。
- scenes/sound.gd に、place.wav と同じフォルダの dead.wav を preload する const SFX_DEAD を足し、func play_sfx の match に "dead"（stream = SFX_DEAD）を足す。
- scenes/main.gd に var last_dead: bool = false を足す。func _refresh で Sound.sfx_for のあと、var curr_dead を「チュートリアルでなく、Rules.dead_marks(session.board, session.level) が空でない」とし、sfx_name が "mark" で last_snapshot が空でなく last_dead が false で curr_dead が true なら sfx_name を "dead" にする。last_conflicts を入れ直すところで last_dead = curr_dead とする。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "dead" なら sound.vibrate(120) を呼ぶ（vibrate は CR-1177 で足したもの）。
- Sound.sfx_for、ほかの効果音の鳴らし方、宇宙人を置いたときの 30 ミリ秒の振動、吹き出しの文、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) してから s.setup() をする。s.play_sfx("dead") をしたあとの s.played は ["dead"]（"dead" の効果音を鳴らせる）。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1) を順にしたあと（区域 0 の 4 マスのうち 3 マスが ×）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1) をしたあと（区域 0 が × だけで埋まり、Rules.dead_marks が空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をして (0, 0) に宇宙人を置き、続けて m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 は宇宙人 1 つと × 3 つ。宇宙人がいる行は × だけの組に数えない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は [30]（宇宙人を置いたときの振動だけ）。続けて m.session.tap(2, 1)、m.session.tap(3, 1) を順にしたあと（区域 1 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [30, 120]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にする（区域 0 が × だけで埋まった）。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 も × だけで埋まったが、× だけの組はその前からあった。空でないときに組が増えても鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(1, 1)、m.session.tap(3, 0) を順にして × を 2 つ消したあと（Rules.dead_marks が空に戻った。× を消したときは何も鳴らない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(3, 0) をしたあと（行 0 が再び × だけで埋まり、空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]) をしたあと（1 回のスワイプで行 3 の 4 マスが × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。
6. テストの関数の中で var Level = load("res://game/level.gd") とし、var level_a = Level.new()、var level_b = Level.new()、var level_c = Level.new() の 3 つの面それぞれに parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level_a, level_b, level_c]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあとの m.sound.vibrations は [120]。続けて m.session.next_level() をしたあと（2 つ目の面に進み、盤は空）の m.session.level_index は 1、m.sound.vibrations は [120]。続けて 2 つ目の面で m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（2 つ目の面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。
7. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（区域 0 が × だけで埋まった盤から始める。読み直した進み具合と同じ形）。add_child_autofree(m) をして await wait_frames(2) をしたあと（最初の _refresh では dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して Rules.dead_marks が空に戻り、再び付けて空でなくなった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。
8. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.tap(0, 2) をしたあと（チュートリアルの盤で 1 マスだけの区域 (0, 2) が × だけで埋まった。チュートリアルの間は dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.end_tutorial() をしてから m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1033.gd::test_sfx_for_mark — Sound.sfx_for は変えない（dead への差し替えは main.gd の _refresh でする）
- test/cr/test_cr_1033.gd::test_sfx_for_place — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_clear — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_hint — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_level_clear — 同じ
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 最初の面の (0, 0) に × を 1 つ付けても × だけの組はできない（(0, 0) の区域は 7 マス）ので "mark" が鳴る
- test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title — "button" は _refresh を通らない
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — チュートリアルの間は dead を鳴らさない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — チュートリアルの間は dead を鳴らさない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — チュートリアルの間は dead を鳴らさない。最後の手は宇宙人を置く手で wrong が先
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — last_snapshot・last_conflicts の入れ方は変えない
- test/cr/test_cr_1151.gd::test_cr_1151_title_screen_sound_integration — 起動画面の "button" は _refresh を通らない
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は読むだけで変えない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 区域 0 を埋めたとき dead が鳴るが、このテストが見ているのは吹き出しの文と help_text だけ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language — 吹き出しの文は変えない
- test/cr/test_cr_1026.gd::test_main_cleared_text_ja — _refresh を呼ぶが、見ているのはクリアの文だけ
- test/cr/test_cr_1073.gd::test_main_clear_effect_integration — _refresh を呼ぶが、見ているのはクリアの演出だけ
- test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve — チュートリアルの間は dead を鳴らさない。見ているのはクリアの演出だけ
- test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile — _refresh を呼ぶが、見ているのは吹き出しだけ
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — _refresh を呼ぶが、見ているのは吹き出しとヒントだけ

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "5 okだけと音（テンション下がる効果音）のスマホの振動を入れて"
  said_at: "2026-10-26 06:28"
  decision: "D-20261026-0622"
  plan: "スマホの振動（置いたとき・× だけの組ができたとき）"
  step: "× だけの組ができた瞬間に dead を鳴らし 120 ミリ秒振動する（CR 3 つ目）"
title: "× だけの組ができた瞬間に音と振動"
probe: req_cr1179_probe.gd
decls:
  scenes/sound.gd:
  - "const SFX_DEAD"
  scenes/main.gd:
  - "var last_dead: bool = false"
files:
  edit: [scenes/sound.gd, scenes/main.gd]
  new: []
human:
  - "Pixel で区域・行・列のどれかを × だけで埋めた瞬間に、テンションが下がる音が鳴り、宇宙人を置いたときより長くブルッと振動することを見る。続けて別の行を × だけで埋めても鳴らないこと、× を消してから埋め直すと再び鳴ることを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) してから s.setup() をする。s.play_sfx("dead") をしたあとの s.played は ["dead"]（"dead" の効果音を鳴らせる）。'
  target: s.play_sfx
  expect:
  - 's.played'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1) を順にしたあと（区域 0 の 4 マスのうち 3 マスが ×）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1) をしたあと（区域 0 が × だけで埋まり、Rules.dead_marks が空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をして (0, 0) に宇宙人を置き、続けて m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 は宇宙人 1 つと × 3 つ。宇宙人がいる行は × だけの組に数えない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は [30]（宇宙人を置いたときの振動だけ）。続けて m.session.tap(2, 1)、m.session.tap(3, 1) を順にしたあと（区域 1 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [30, 120]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R4
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にする（区域 0 が × だけで埋まった）。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 も × だけで埋まったが、× だけの組はその前からあった。空でないときに組が増えても鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(1, 1)、m.session.tap(3, 0) を順にして × を 2 つ消したあと（Rules.dead_marks が空に戻った。× を消したときは何も鳴らない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(3, 0) をしたあと（行 0 が再び × だけで埋まり、空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R5
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]) をしたあと（1 回のスワイプで行 3 の 4 マスが × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。'
  target: m.session.swipe
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R6
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level_a = Level.new()、var level_b = Level.new()、var level_c = Level.new() の 3 つの面それぞれに parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level_a, level_b, level_c]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあとの m.sound.vibrations は [120]。続けて m.session.next_level() をしたあと（2 つ目の面に進み、盤は空）の m.session.level_index は 1、m.sound.vibrations は [120]。続けて 2 つ目の面で m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（2 つ目の面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。'
  target: m.session.next_level
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R7
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（区域 0 が × だけで埋まった盤から始める。読み直した進み具合と同じ形）。add_child_autofree(m) をして await wait_frames(2) をしたあと（最初の _refresh では dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して Rules.dead_marks が空に戻り、再び付けて空でなくなった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R8
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.tap(0, 2) をしたあと（チュートリアルの盤で 1 マスだけの区域 (0, 2) が × だけで埋まった。チュートリアルの間は dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.end_tutorial() をしてから m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, game/tutorial.gd, scenes/board_view.gd]
  other:
  - 'scenes/sound.gd の Sound.sfx_for は変えない'
  - 'scenes/main.gd の宇宙人を置いたときの 30 ミリ秒の振動と吹き出しの文（help_text・dead_marks_text）は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1033.gd::test_sfx_for_mark'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_place'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_clear'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_hint'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_wrong'
  - 'test/cr/test_cr_1033.gd::test_sfx_for_level_clear'
  - 'test/cr/test_cr_1033.gd::test_main_played_mark_on_tap'
  - 'test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title'
  - 'test/cr/test_cr_1038.gd::test_tutorial_place_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_mark_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_wrong_sound'
  - 'test/cr/test_cr_1038.gd::test_tutorial_init_last_values'
  - 'test/cr/test_cr_1151.gd::test_cr_1151_title_screen_sound_integration'
  - 'test/cr/test_cr_1173.gd::test_dead_marks_basic'
  - 'test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language'
  - 'test/cr/test_cr_1026.gd::test_main_cleared_text_ja'
  - 'test/cr/test_cr_1073.gd::test_main_clear_effect_integration'
  - 'test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve'
  - 'test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile'
  - 'test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change'
```


## CR（CR-1179-1179v.local.md）

# CR-1179: × だけの組ができた瞬間に音と振動

## 変えること
- scenes/sound.gd に、place.wav と同じフォルダの dead.wav を preload する const SFX_DEAD を足し、func play_sfx の match に "dead"（stream = SFX_DEAD）を足す。
- scenes/main.gd に var last_dead: bool = false を足す。func _refresh で Sound.sfx_for のあと、var curr_dead を「チュートリアルでなく、Rules.dead_marks(session.board, session.level) が空でない」とし、sfx_name が "mark" で last_snapshot が空でなく last_dead が false で curr_dead が true なら sfx_name を "dead" にする。last_conflicts を入れ直すところで last_dead = curr_dead とする。
- scenes/main.gd の func _refresh で sound.play_sfx(sfx_name) を呼んだあと、sfx_name が "dead" なら sound.vibrate(120) を呼ぶ（vibrate は CR-1177 で足したもの）。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/sound.gd`: `SFX_PLACE`、`SFX_MARK`、`SFX_CLEAR`、`SFX_HINT`、`SFX_WRONG`、`SFX_LEVEL_CLEAR`、`SFX_BUTTON`、`BGM_MAIN`、`BGM_TITLE`、`BGM_STAGE1`、`BGM_STAGE2`、`BGM_STAGE3`、`BGM_STAGE4`、`music_name`、`sfx_player`、`music_player`、`play_music`、`stop_music`、`bgm_for_size`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`start_with_tutorial`、`space_bg`、`language`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: game/tutorial.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd の Sound.sfx_for は変えない（依頼の欄）
- 依頼の欄: scenes/main.gd の宇宙人を置いたときの 30 ミリ秒の振動と吹き出しの文（help_text・dead_marks_text）は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/sound.gd` に足す（既存のファイルに足す）
  - `const SFX_DEAD`
- `res://scenes/main.gd` に足す（既存のファイルに足す）
  - `var last_dead: bool = false`

## 自動で確かめること
1. テストの関数の中で var S = load("res://scenes/sound.gd") とし、var s = S.new() を add_child_autofree(s) してから s.setup() をする。s.play_sfx("dead") をしたあとの s.played は ["dead"]（"dead" の効果音を鳴らせる）。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1) を順にしたあと（区域 0 の 4 マスのうち 3 マスが ×）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1) をしたあと（区域 0 が × だけで埋まり、Rules.dead_marks が空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.double_tap(0, 0) をして (0, 0) に宇宙人を置き、続けて m.session.tap(1, 0)、m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 は宇宙人 1 つと × 3 つ。宇宙人がいる行は × だけの組に数えない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は [30]（宇宙人を置いたときの振動だけ）。続けて m.session.tap(2, 1)、m.session.tap(3, 1) を順にしたあと（区域 1 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [30, 120]。
4. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にする（区域 0 が × だけで埋まった）。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（行 0 も × だけで埋まったが、× だけの組はその前からあった。空でないときに組が増えても鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(1, 1)、m.session.tap(3, 0) を順にして × を 2 つ消したあと（Rules.dead_marks が空に戻った。× を消したときは何も鳴らない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [120]。続けて m.session.tap(3, 0) をしたあと（行 0 が再び × だけで埋まり、空から空でなくなった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。
5. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.swipe([Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]) をしたあと（1 回のスワイプで行 3 の 4 マスが × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。
6. テストの関数の中で var Level = load("res://game/level.gd") とし、var level_a = Level.new()、var level_b = Level.new()、var level_c = Level.new() の 3 つの面それぞれに parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level_a, level_b, level_c]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあとの m.sound.vibrations は [120]。続けて m.session.next_level() をしたあと（2 つ目の面に進み、盤は空）の m.session.level_index は 1、m.sound.vibrations は [120]。続けて 2 つ目の面で m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（2 つ目の面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [120, 120]。
7. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) の前に m.session.board.apply("mark", 0, 0)、m.session.board.apply("mark", 1, 0)、m.session.board.apply("mark", 0, 1)、m.session.board.apply("mark", 1, 1) をしておく（区域 0 が × だけで埋まった盤から始める。読み直した進み具合と同じ形）。add_child_autofree(m) をして await wait_frames(2) をしたあと（最初の _refresh では dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.session.tap(1, 1)、m.session.tap(1, 1) を順にしたあと（× を消して Rules.dead_marks が空に戻り、再び付けて空でなくなった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。
8. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.start_tutorial() をしてから m.tutorial.session.tap(0, 2) をしたあと（チュートリアルの盤で 1 マスだけの区域 (0, 2) が × だけで埋まった。チュートリアルの間は dead を鳴らさない）の m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 0 で、m.sound.vibrations は []。続けて m.end_tutorial() をしてから m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（チュートリアルを終えたあとの面で区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.vibrations は [120]。
9. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で区域・行・列のどれかを × だけで埋めた瞬間に、テンションが下がる音が鳴り、宇宙人を置いたときより長くブルッと振動することを見る。続けて別の行を × だけで埋めても鳴らないこと、× を消してから埋め直すと再び鳴ることを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1033.gd::test_sfx_for_mark — Sound.sfx_for は変えない（dead への差し替えは main.gd の _refresh でする）
- test/cr/test_cr_1033.gd::test_sfx_for_place — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_clear — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_hint — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_wrong — 同じ
- test/cr/test_cr_1033.gd::test_sfx_for_level_clear — 同じ
- test/cr/test_cr_1033.gd::test_main_played_mark_on_tap — 最初の面の (0, 0) に × を 1 つ付けても × だけの組はできない（(0, 0) の区域は 7 マス）ので "mark" が鳴る
- test/cr/test_cr_1033.gd::test_button_sfx_in_main_and_title — "button" は _refresh を通らない
- test/cr/test_cr_1038.gd::test_tutorial_place_sound — チュートリアルの間は dead を鳴らさない
- test/cr/test_cr_1038.gd::test_tutorial_mark_sound — チュートリアルの間は dead を鳴らさない
- test/cr/test_cr_1038.gd::test_tutorial_wrong_sound — チュートリアルの間は dead を鳴らさない。最後の手は宇宙人を置く手で wrong が先
- test/cr/test_cr_1038.gd::test_tutorial_init_last_values — last_snapshot・last_conflicts の入れ方は変えない
- test/cr/test_cr_1151.gd::test_cr_1151_title_screen_sound_integration — 起動画面の "button" は _refresh を通らない
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は読むだけで変えない
- test/cr/test_cr_1173.gd::test_mark_color_at_dead_marks — 同じ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 区域 0 を埋めたとき dead が鳴るが、このテストが見ているのは吹き出しの文と help_text だけ
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_text_language — 吹き出しの文は変えない
- test/cr/test_cr_1026.gd::test_main_cleared_text_ja — _refresh を呼ぶが、見ているのはクリアの文だけ
- test/cr/test_cr_1073.gd::test_main_clear_effect_integration — _refresh を呼ぶが、見ているのはクリアの演出だけ
- test/cr/test_cr_1078.gd::test_cr_1078_clear_effect_on_tutorial_solve — チュートリアルの間は dead を鳴らさない。見ているのはクリアの演出だけ
- test/cr/test_cr_1084.gd::test_cr_1084_refresh_during_tutorial_and_end_restores_tile — _refresh を呼ぶが、見ているのは吹き出しだけ
- test/cr/test_cr_1134.gd::test_refresh_clears_bubble_on_board_change — _refresh を呼ぶが、見ているのは吹き出しとヒントだけ

## 対象の候補
- edit: `scenes/sound.gd`、`scenes/main.gd`
