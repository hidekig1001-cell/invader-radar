# クラウドへの依頼: InvaderRadar改修1187 の R0'（CR.md を読む）（1 回目、2026-10-27 16:3x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 0ae3435（v1.94-cr1185）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、クラウドが下書きした draft/bug-dead-radar の drafts/req_bug_dead_new_group.txt（probe の名前だけ手元の req_cr1187_probe.gd に替えた）。× だけの組が新しくできるたびに dead の音と振動を出す（音A）。ユーザーの判断 D-20261027-1607＝A（新しい組ごとに鳴らす）。振動の長さと強さは変えない（ユーザー「振動自体はすごく良い」）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。
手元の当て試し（main 0ae3435 の写し）では、直しを当てると落ちたのは「変わる既存のテスト」の 2 つ（test_cr_1179_main_dead_retrigger・test_cr_1182_dead_vibration_not_retriggered）だけで、依頼に書いた差のとおり。直しなしでは probe の 3 件だけが落ちた。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。既存のテストの書き直しは run の段が「変わる既存のテスト」の節に従って行う。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（新しく dead_marks に入ったマスがある手で鳴らす、"mark" と "clear" の手を dead に替える、効果音の順、チュートリアルと最初の _refresh では鳴らさない、振動の長さと強さは変えない）が CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目の手順と期待値を落とさず写しているか。依頼の中心の条件（2 つ目の組でも鳴る、元に戻す手で × だけになっても鳴る、すでにある組に × が足されないときは鳴らない）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/main.gd の last_dead を last_dead_marks に替える所、dead に替える条件）が依頼と合っているか。依頼に無い箇条・余計な変更（振動の長さと強さ・line の決まり・ほかのファイルを変えるなど）・抜けが無いか。
3. 「変わる既存のテスト」の 2 つ（差の書き方まで）と「変わらない既存のテスト」が CR に写っているか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1187-r0p）のファイル results/cr1187_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1187.txt）

× だけの組（行・列・区域）が新しくできるたびに、dead の音と振動を出して（ユーザーの Pixel の確かめ 10/27 16:0x「1179,1182 この状態で、音と振動がならない」。レベル 6 で橙の区域と桃の区域の 2 つが × だけになっていた）。今の決まり（CR-1179）は「Rules.dead_marks が空から空でなくなった手だけ鳴らす」なので、× だけの組がすでに 1 つあると、2 つ目・3 つ目の組ができても鳴らない。これを「前の手のあとには × だけの組に入っていなかった × が、この手のあとに × だけの組に入った（新しい × だけの組ができた）手で鳴らす」に替える。あわせて、元に戻す（undo）で × が戻って × だけの組ができた手は、効果音が clear（宇宙人が減った手）になって dead に替わらないので、clear の手も dead に替える（効果音の順 level_clear > wrong > hint > dead > line > clear > place > mark のとおり）。チュートリアルの間と、main を立ち上げた最初の _refresh では鳴らさない（今と同じ）。dead の振動の長さと強さ（250 ミリ秒・0.3）は変えない。

- scenes/main.gd の var last_dead: bool = false を var last_dead_marks: Array = [] に替える（前の手のあとの Rules.dead_marks の並び）。
- scenes/main.gd の func _refresh で、curr_dead を作る所を、var curr_dead_marks: Array を「チュートリアルでなければ Rules.dead_marks(session.board, session.level)、チュートリアルなら []」とする形に替える。curr_dead_marks のマスのうち 1 つでも last_dead_marks に無いものがあり、sfx_name が "mark" か "clear" で、last_snapshot が空でなければ sfx_name を "dead" にする。last_dead = curr_dead としていた所は last_dead_marks = curr_dead_marks にする。
- scenes/main.gd の func start_tutorial の last_dead = false は last_dead_marks = [] に、func end_tutorial の last_dead = not Rules.dead_marks(session.board, session.level).is_empty() は last_dead_marks = Rules.dead_marks(session.board, session.level) に替える。
- Rules.dead_marks、Sound.sfx_for、line に替える決まり（last_lines・curr_lines・new_lines）、振動の長さと強さ、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 2) をしたあと（× だけの組は増えない）の m.sound.played[-1] は "mark"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 0 が × だけのまま、区域 3 も × だけで埋まった。2 つ目の × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（区域 0 と重なる行 0 も × だけで埋まった。新しい × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 250]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.double_tap(1, 1) をしたあと（(1, 1) の × を宇宙人に替え、区域 0 は宇宙人 1 つと × 3 つでそろった）の m.sound.played[-1] は "line"、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.undo() をしたあと（(1, 1) が × に戻り、区域 0 が再び × だけになった。効果音は clear の手）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 250]。

変わる既存のテスト:
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — m.session.tap(2, 0)・m.session.tap(3, 0) のあと（行 0 が新しく × だけになったので dead が鳴る）と、m.session.tap(1, 1)・m.session.tap(3, 0) のあとの assert_eq(m.sound.played.count("dead"), 1)（2 か所とも）は assert_eq(m.sound.played.count("dead"), 2) に、同じ 2 か所の assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])（2 か所とも）は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250]) に、最後の assert_eq(m.sound.played.count("dead"), 2) は assert_eq(m.sound.played.count("dead"), 3) に、最後の assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 250]) は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250, 250]) に変わる（最初の m.session.tap(1, 1) のあとの assert_eq(m.sound.played.count("dead"), 1) と assert_eq(m.sound.vibrations, [15, 15, 15, 250]) は変えない。関数の名前とコメントは変えない）
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered — m.session.tap(2, 0)・m.session.tap(3, 0) のあとの assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15]) は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250]) に、assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4]) は assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.3]) に変わる（行 0 が新しく × だけになった手で dead の振動が出る。関数の名前は古くなるが変えない）

変わらない既存のテスト:
- test/cr/test_cr_1179.gd::test_cr_1179_sound_dead_sfx — 効果音を直に鳴らすだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — × だけの組は 1 つだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 宇宙人のいる行は × だけの組に数えない。× だけの組は区域 1 の 1 つだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 1 回のスワイプで組が 1 つできる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 次の面の盤は空なので、last_dead_marks は [] に戻る
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 最初の _refresh では鳴らさず、× を消して付け直すと (1, 1) が新しく組に入るので鳴る
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — チュートリアルの間は鳴らさない
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition — × だけの組は 1 つだけ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 列 3 が × だけになる手は今と同じく dead、そのあとの区域 0 は line
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 見ているのは吹き出しの文だけ
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: '1179,1182 この状態で、音と振動がならない。'
  said_at: "2026-10-27 16:0x"
  decision: "未定（ユーザーの判断の後に入れる）"
  plan: "Pixel の確かめ（0ae3435）の指摘を直す"
  step: "× だけの組が新しくできるたびに dead を鳴らす"
title: "× だけの組が新しくできるたびに dead の音と振動"
probe: req_cr1187_probe.gd
decls:
  scenes/main.gd:
  - "var last_dead_marks: Array = []"
files:
  edit: [scenes/main.gd]
  new: []
human:
  - "Pixel でレベル 6 の橙の区域を × だけにして dead が鳴ったあと、桃の区域も × だけにしたときにも、もう一度 dead の音と 250 ミリ秒の弱めの振動が出ることを見る。× だけの組が増えない × では鳴らないことを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 2) をしたあと（× だけの組は増えない）の m.sound.played[-1] は "mark"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 0 が × だけのまま、区域 3 も × だけで埋まった。2 つ目の × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R2
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（区域 0 と重なる行 0 も × だけで埋まった。新しい × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 250]。'
  target: m.session.tap
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
- id: R3
  text: 'テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.double_tap(1, 1) をしたあと（(1, 1) の × を宇宙人に替え、区域 0 は宇宙人 1 つと × 3 つでそろった）の m.sound.played[-1] は "line"、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.undo() をしたあと（(1, 1) が × に戻り、区域 0 が再び × だけになった。効果音は clear の手）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 250]。'
  target: m.session.undo
  expect:
  - 'm.sound.played[-1]'
  - 'm.sound.vibrations'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, scenes/sound.gd, scenes/board_view.gd]
  other:
  - 'scenes/main.gd の line に替える決まり（last_lines・curr_lines・new_lines）と振動の長さと強さは変えない'
changing_tests:
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered'
unchanged_tests:
  - 'test/cr/test_cr_1179.gd::test_cr_1179_sound_dead_sfx'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state'
  - 'test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial'
  - 'test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude'
  - 'test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe'
  - 'test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line'
  - 'test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning'
  - 'test/cr/test_cr_1173.gd::test_dead_marks_basic'
```

## CR（CR-1187-1187v.local.md）

# CR-1187: × だけの組が新しくできるたびに dead の音と振動

## 変えること
- scenes/main.gd の var last_dead: bool = false を var last_dead_marks: Array = [] に替える（前の手のあとの Rules.dead_marks の並び）。
- scenes/main.gd の func _refresh で、curr_dead を作る所を、var curr_dead_marks: Array を「チュートリアルでなければ Rules.dead_marks(session.board, session.level)、チュートリアルなら []」とする形に替える。curr_dead_marks のマスのうち 1 つでも last_dead_marks に無いものがあり、sfx_name が "mark" か "clear" で、last_snapshot が空でなければ sfx_name を "dead" にする。last_dead = curr_dead としていた所は last_dead_marks = curr_dead_marks にする。
- scenes/main.gd の func start_tutorial の last_dead = false は last_dead_marks = [] に、func end_tutorial の last_dead = not Rules.dead_marks(session.board, session.level).is_empty() は last_dead_marks = Rules.dead_marks(session.board, session.level) に替える。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/message_bubble.gd`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_conflicts`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`board_view`、`hud`、`bubble`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`size_up_tile_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tick_size_up`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/main.gd の line に替える決まり（last_lines・curr_lines・new_lines）と振動の長さと強さは変えない（依頼の欄）

## 新しい宣言
- `res://scenes/main.gd` に足す（既存のファイルに足す）
  - `var last_dead_marks: Array = []`

## 自動で確かめること
1. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 2) をしたあと（× だけの組は増えない）の m.sound.played[-1] は "mark"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1。続けて m.session.tap(3, 2)、m.session.tap(2, 3)、m.session.tap(3, 3) を順にしたあと（区域 0 が × だけのまま、区域 3 も × だけで埋まった。2 つ目の × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 15, 15, 250]。
2. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.tap(2, 0)、m.session.tap(3, 0) を順にしたあと（区域 0 と重なる行 0 も × だけで埋まった。新しい × だけの組）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 15, 250]。
3. テストの関数の中で var Level = load("res://game/level.gd") とし、var level = Level.new() として level.parse({"width": 4, "height": 4, "target": 4, "regions": [[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]}) をする（区域 0 は (0, 0)・(1, 0)・(0, 1)・(1, 1)、区域 1 は (2, 0)・(3, 0)・(2, 1)・(3, 1)、区域 2 は (0, 2)・(1, 2)・(0, 3)・(1, 3)、区域 3 は (2, 2)・(3, 2)・(2, 3)・(3, 3)。マスは (x, y) で、x は左から数えた列、y は上から数えた行）。var Main = load("res://scenes/main.tscn")、var SessionScript = load("res://game/session.gd") とする。var m = Main.instantiate() として m.session = SessionScript.new([level]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.tap(0, 0)、m.session.tap(1, 0)、m.session.tap(0, 1)、m.session.tap(1, 1) を順にしたあと（区域 0 が × だけで埋まった）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 1、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.double_tap(1, 1) をしたあと（(1, 1) の × を宇宙人に替え、区域 0 は宇宙人 1 つと × 3 つでそろった）の m.sound.played[-1] は "line"、m.sound.vibrations は [15, 15, 15, 250]。続けて m.session.undo() をしたあと（(1, 1) が × に戻り、区域 0 が再び × だけになった。効果音は clear の手）の m.sound.played[-1] は "dead"、m.sound.played の中の "dead" の数（m.sound.played.count("dead")）は 2、m.sound.vibrations は [15, 15, 15, 250, 250]。
4. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel でレベル 6 の橙の区域を × だけにして dead が鳴ったあと、桃の区域も × だけにしたときにも、もう一度 dead の音と 250 ミリ秒の弱めの振動が出ることを見る。× だけの組が増えない × では鳴らないことを見る。

## 変わる既存のテスト
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_retrigger — m.session.tap(2, 0)・m.session.tap(3, 0) のあと（行 0 が新しく × だけになったので dead が鳴る）と、m.session.tap(1, 1)・m.session.tap(3, 0) のあとの assert_eq(m.sound.played.count("dead"), 1)（2 か所とも）は assert_eq(m.sound.played.count("dead"), 2) に、同じ 2 か所の assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15])（2 か所とも）は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250]) に、最後の assert_eq(m.sound.played.count("dead"), 2) は assert_eq(m.sound.played.count("dead"), 3) に、最後の assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15, 250]) は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250, 250]) に変わる（最初の m.session.tap(1, 1) のあとの assert_eq(m.sound.played.count("dead"), 1) と assert_eq(m.sound.vibrations, [15, 15, 15, 250]) は変えない。関数の名前とコメントは変えない）
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_not_retriggered — m.session.tap(2, 0)・m.session.tap(3, 0) のあとの assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 15]) は assert_eq(m.sound.vibrations, [15, 15, 15, 250, 15, 250]) に、assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.4]) は assert_eq(m.sound.vibration_amplitudes, [0.4, 0.4, 0.4, 0.3, 0.4, 0.3]) に変わる（行 0 が新しく × だけになった手で dead の振動が出る。関数の名前は古くなるが変えない）

## 変わらない既存のテスト
- test/cr/test_cr_1179.gd::test_cr_1179_sound_dead_sfx — 効果音を直に鳴らすだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_transition — × だけの組は 1 つだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — 宇宙人のいる行は × だけの組に数えない。× だけの組は区域 1 の 1 つだけ
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_swipe — 1 回のスワイプで組が 1 つできる
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_next_level — 次の面の盤は空なので、last_dead_marks は [] に戻る
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_initial_state — 最初の _refresh では鳴らさず、× を消して付け直すと (1, 1) が新しく組に入るので鳴る
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_tutorial — チュートリアルの間は鳴らさない
- test/cr/test_cr_1180.gd::test_cr_1180_main_vibrate_on_dead_transition — × だけの組は 1 つだけ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude — 同じ
- test/cr/test_cr_1182.gd::test_cr_1182_dead_vibration_on_swipe — 同じ
- test/cr/test_cr_1184.gd::test_cr_1184_dead_priority_over_line — 列 3 が × だけになる手は今と同じく dead、そのあとの区域 0 は line
- test/cr/test_cr_1174.gd::test_cr_1174_dead_marks_warning — 見ているのは吹き出しの文だけ
- test/cr/test_cr_1173.gd::test_dead_marks_basic — Rules.dead_marks は変えない

## 対象の候補
- edit: `scenes/main.gd`
