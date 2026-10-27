# クラウドへの依頼: InvaderRadar改修1188 の R0'（CR.md を読む）（1 回目、2026-10-27 17:4x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar。読み比べに使う main は 9193cdf（v1.96-cr1186。1187 の dead と 1186 の数字の岩が入った版）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
依頼は、あなた（または前のクラウド）が下書きして直した draft/notice の drafts/req_notice.txt（probe の名前だけ手元の req_cr1188_probe.gd に替えた）。盤が大きくなる面のお知らせを金色の札にしてぽんと弾ませ、line の音と 60 ms・強さ 0.6 の振動を出す（案 A、ユーザーの判断 D-20261027-1615＝A）。CR は AuteDev の CR を作る役（機械の経路、Ubuntu4 の Qwen-next-flash の役名）が作った。
手元の当て試し（main 70d8d6b の写し）では、直しを当てると 746 件すべて通り、直しなしでは probe の 5 件だけが落ちた。依頼の検査は R-C28・R-RED の直しの後で error 0。

## AuteDev の決まり（読み違えないために）
- CR の「変えないこと」に test/ があるのは AuteDev が機械で書く決まった欄。NG の理由にしない。
- 新しいテストは run の中で tests/test_cr_<番号>.gd に作られ、取り込みで test/cr/ に入る。
- 依頼の頭の段落の決まりは CR に写らないことがある（1183）。決まり（金色の札はお知らせだけ、面のクリアの札はピンクのまま、0.6 秒待つ・0.8 秒消さない決まりは変えない、字の上限 52、clear_text で戻す）が CR の変えることか確かめる項目に写っているかを見る。

## 見ること
1. CR の確かめる項目が、依頼の確かめる項目 1〜5 の手順と期待値（色・縁・弾みの大きさ・誤差・size_up_mode・pop_age・音と振動）を落とさず写しているか。依頼の中心の条件（お知らせは金色で弾む、クリアの札はピンクのまま、出るときに line の音と 60 ms・0.6 の振動、clear_text で元に戻る）を確かめる項目が無ければ NG。
2. CR の変えること（scenes/message_bubble.gd の show_size_up・size_up_box・size_up_pop_scale・step_pop・clear_text の戻し、scenes/main.gd の tick_size_up）が依頼と合っているか。依頼に無い箇条・余計な変更（クリアの札・吹き出しの大きさ・1187 の dead・1184 の line の決まりを変えるなど）・抜けが無いか。
3. 「変わる既存のテスト: なし」と「変わらない既存のテスト」の 14 個（test_cr_1135・test_pixel_1023 を含む）が CR に写っているか。14 個の名前が main 9193cdf に実際にあるか。

## 終わりの条件（必ず守る）
- 結果を、この branch（review/cr1188-r0p）のファイル results/cr1188_r0p.md に書いて commit・push する。1 行目は「R0' OK」か「R0' NG: <理由>」、続けて項目ごとの見立てを短く。NG なら、依頼の「変えること」か「確かめる項目」をどう直せばよいかを、そのまま貼れる文で書く。main・ほかの branch には触らない。
## 依頼（req_cr1188.txt）

盤が大きくなる面のお知らせ（CR-1178 で盤を見せて 0.6 秒後に出す）を、もっと派手に、見た目で分かりやすくして（ユーザーの Pixel の確かめ 10/27 15:5x「１１７８　もっとはでに見た目がわかりやすく。」）。
今のお知らせは、面のクリアと同じピンクのタイル（show_tile）で、音も振動も動きも無い。お知らせだけを、金色の地・太い濃い橙の縁のタイルにして、出たときに 0.3 秒ぽんと弾ませ（いちばん大きいとき 1.25 倍）、そろった音 "line" を鳴らし、60 ミリ秒・強さ 0.6 で振動させる。字は 2 行に収まる大きさ（上限 52）にする。面のクリアのタイルは今のピンクにして、2 つを見分けられるようにする。
- scenes/message_bubble.gd に const SIZE_UP_BG := Color8(255, 215, 64)、const SIZE_UP_BORDER := Color8(230, 110, 20)、const SIZE_UP_POP_TIME := 0.3、var size_up_mode: bool = false、var pop_age: float = -1.0 を足す。func size_up_box() -> StyleBoxFlat を足し、地の色 SIZE_UP_BG・縁の色 SIZE_UP_BORDER・縁の太さ 8（4 辺とも）・角の丸み 24（4 隅とも）・anti_aliasing true の新しい StyleBoxFlat を返す。
- scenes/message_bubble.gd に func show_size_up(text_to_show: String, center: Vector2) -> void を足す。show_tile(text_to_show, center) を呼んだあと、size_up_mode = true とし、"normal" の stylebox を size_up_box() に、"font_size" を fit_font_size(text_to_show, TILE_SIZE, 52, 36) にし、pivot_offset = TILE_SIZE / 2.0、pop_age = 0.0、scale = Vector2.ONE とする。
- scenes/message_bubble.gd に static func size_up_pop_scale(age: float) -> float を足す（age が 0 未満か SIZE_UP_POP_TIME 以上なら 1.0、ほかは 1.0 + 0.25 * sin(PI * age / SIZE_UP_POP_TIME)）。func step_pop(delta: float) -> void を足す（pop_age が 0 未満なら何もしない。pop_age に delta を足し、SIZE_UP_POP_TIME 以上になったら pop_age = -1.0・scale = Vector2.ONE、ほかは scale = Vector2(s, s)。s は size_up_pop_scale(pop_age)）。func _process で step_blink(delta) のあとに step_pop(delta) を呼ぶ。func clear_text で、tile_mode を戻す前に、size_up_mode が true なら size_up_mode = false・pop_age = -1.0・scale = Vector2.ONE・"font_size" を FONT_SIZE にする。
- scenes/main.gd の func tick_size_up で、bubble.show_tile(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) の代わりに bubble.show_size_up(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) を呼び、続けて sound.play_sfx("line") と sound.vibrate(60, 0.6) を呼ぶ。
- show_tile と面のクリアのタイルの色、吹き出しとチュートリアルのパネル、size_up_wait・size_up_age の決まり（0.6 秒待つ・0.8 秒は消さない）、ほかのファイルは変えない。

確かめてほしいこと（自動で確かめる項目。依頼の中心）:
1. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.tile_mode は true、b.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"。b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色）、border_color は Color8(230, 110, 20)（濃い橙）、border_width_top は 8。b.get_theme_font_size("font_size") は b.fit_font_size("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", B.TILE_SIZE, 52, 36) と同じ値。b.pivot_offset は Vector2(450, 80)（タイルの真ん中）、b.pop_age は 0.0（誤差 0.001 まで）。
2. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とする。B.size_up_pop_scale(0.15) は 1.25、B.size_up_pop_scale(0.075) は 1.1768、B.size_up_pop_scale(0.0) は 1.0、B.size_up_pop_scale(0.3) は 1.0、B.size_up_pop_scale(-1.0) は 1.0（どれも誤差 0.001 まで。0.15 秒でいちばん大きく 1.25 倍になり、0.3 秒で元の大きさに戻る）。
3. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。続けて b.step_pop(0.15) をしたあとの b.pop_age は 0.15（誤差 0.001 まで）、b.scale は Vector2(1.25, 1.25)（誤差 0.001 まで）。続けて b.step_pop(0.2) をしたあと（0.3 秒を過ぎた）の b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)。
4. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色の札が出た）。続けて b.step_pop(0.1) をしたあとの b.scale は Vector2(1.2165, 1.2165)（誤差 0.001 まで。弾んでいる途中）。続けて b.clear_text() をしたあとの b.size_up_mode は false、b.tile_mode は false、b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)、b.get_theme_stylebox("normal") は b.normal_box と同じもの、b.get_theme_font_size("font_size") は B.FONT_SIZE と同じ値。
5. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var l1 = Level.new() に l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})、var l2 = Level.new() に l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})、var l3 = Level.new() に l2 と同じ形で id だけ 3 の parse をする（面は 3 つ。2 つ目の面から盤が 5×5 になる）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと（1 つ目の面をクリアした。クリアのタイルは金色にしない）の m.bubble.tile_mode は true、m.bubble.size_up_mode は false。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) とし、m._input(down) をしたあと（2 つ目の面に進んだ）の m.session.level_index は 1、m.sound.played の中の "line" の数（m.sound.played.count("line")）は 0。続けて m.tick_size_up(0.7) をしたあと（0.6 秒待って、お知らせが出た）の m.bubble.size_up_mode は true、m.bubble.text は m.size_up_tile_text() と同じ文、m.bubble.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)、m.sound.played の中の "line" の数は 1、m.sound.vibrations の最後は 60、m.sound.vibration_amplitudes の最後は 0.6（誤差 0.001 まで）。

変わる既存のテスト: なし。

変わらない既存のテスト:
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — 0.6 秒待って出る・0.8 秒は消さない決まりは変えない。tile_mode と文は今と同じ
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 字の大きさの上限 52 で、日本語のお知らせは 2 行に収まる（get_line_count は 2）
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — お知らせの文は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — size_up_text は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en — 同じ
- test/cr/test_cr_1076.gd::test_show_tile_and_clear_text — show_tile は変えない
- test/cr/test_cr_1076.gd::test_main_integration_tile — 面のクリアのタイルは show_tile で出す
- test/cr/test_cr_1095.gd::test_cr_1095_clear_tile_box_style — ピンクのタイル（clear_tile_box）は変えない
- test/cr/test_cr_1141.gd::test_cr_1141_clear_text_restores_normal_style — clear_text は、金色のタイルのときだけ戻すものを足す。ふつうの吹き出しの戻し方は変えない
- test/cr/test_pixel_1023.gd::test_pixel_1023_bubble_is_orange_with_white_text — 吹き出しの色は変えない
- test/cr/test_cr_1091.gd::test_cr_1091_step_blink_panel_mode — パネルの点滅（step_blink）は変えない
- test/cr/test_cr_1086.gd::test_cr_1086_show_panel_and_clear_text_style — パネルは変えない
- test/cr/test_cr_1135.gd::test_cr_1135_bubble_geometry_and_font — 金色の札を出さない道（show_panel と clear_text）だけを見ている。clear_text に足す戻しは size_up_mode が true のときだけ動くので、位置・大きさ・字の大きさ 36・48・36 は変わらない
- test/cr/test_pixel_1023.gd::test_pixel_1023_fit_font_size — fit_font_size と text_height は変えない（show_size_up は fit_font_size を呼ぶだけ）。show_text・show_panel の字の大きさと枠の大きさも変わらない

## 依頼の欄（YAML）
```yaml
origin:
  user_text: "１１７８　もっとはでに見た目がわかりやすく。"
  said_at: "2026-10-27 15:5x"
  decision: "D-20261027-1615"
  plan: "手触り（盤が大きくなる面のお知らせ）"
  step: "お知らせを金色のタイルにして弾ませ、音と振動を出す（案 A）"
title: "盤が大きくなる面のお知らせを派手にする"
probe: req_cr1188_probe.gd
decls:
  scenes/message_bubble.gd:
  - "const SIZE_UP_BG := Color8(255, 215, 64)"
  - "const SIZE_UP_BORDER := Color8(230, 110, 20)"
  - "const SIZE_UP_POP_TIME := 0.3"
  - "var size_up_mode: bool = false"
  - "var pop_age: float = -1.0"
  - "func size_up_box() -> StyleBoxFlat"
  - "func show_size_up(text_to_show: String, center: Vector2) -> void"
  - "static func size_up_pop_scale(age: float) -> float"
  - "func step_pop(delta: float) -> void"
files:
  edit: [scenes/message_bubble.gd, scenes/main.gd]
  new: []
human:
  - "Pixel で 4×4 の最後の面をクリアして次の面に進み、盤が見えてから金色のお知らせがぽんと弾んで出て、音と短い振動が来ることを見る。面のクリアのタイル（ピンク）と見分けられるかを見る。"
checks:
- id: R1
  text: 'テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.tile_mode は true、b.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"。b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色）、border_color は Color8(230, 110, 20)（濃い橙）、border_width_top は 8。b.get_theme_font_size("font_size") は b.fit_font_size("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", B.TILE_SIZE, 52, 36) と同じ値。b.pivot_offset は Vector2(450, 80)（タイルの真ん中）、b.pop_age は 0.0（誤差 0.001 まで）。'
  target: b.show_size_up
  expect:
  - 'b.size_up_mode'
  - 'b.get_theme_stylebox("normal")'
- id: R2
  text: 'テストの関数の中で var B = load("res://scenes/message_bubble.gd") とする。B.size_up_pop_scale(0.15) は 1.25、B.size_up_pop_scale(0.075) は 1.1768、B.size_up_pop_scale(0.0) は 1.0、B.size_up_pop_scale(0.3) は 1.0、B.size_up_pop_scale(-1.0) は 1.0（どれも誤差 0.001 まで。0.15 秒でいちばん大きく 1.25 倍になり、0.3 秒で元の大きさに戻る）。'
  target: B.size_up_pop_scale
  expect:
  - 'B.size_up_pop_scale'
- id: R3
  text: 'テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。続けて b.step_pop(0.15) をしたあとの b.pop_age は 0.15（誤差 0.001 まで）、b.scale は Vector2(1.25, 1.25)（誤差 0.001 まで）。続けて b.step_pop(0.2) をしたあと（0.3 秒を過ぎた）の b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)。'
  target: b.step_pop
  expect:
  - 'b.pop_age'
  - 'b.scale'
- id: R4
  text: 'テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色の札が出た）。続けて b.step_pop(0.1) をしたあとの b.scale は Vector2(1.2165, 1.2165)（誤差 0.001 まで。弾んでいる途中）。続けて b.clear_text() をしたあとの b.size_up_mode は false、b.tile_mode は false、b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)、b.get_theme_stylebox("normal") は b.normal_box と同じもの、b.get_theme_font_size("font_size") は B.FONT_SIZE と同じ値。'
  target: b.clear_text
  expect:
  - 'b.size_up_mode'
  - 'b.scale'
  - 'b.get_theme_stylebox("normal")'
- id: R5
  text: 'テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var l1 = Level.new() に l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})、var l2 = Level.new() に l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})、var l3 = Level.new() に l2 と同じ形で id だけ 3 の parse をする（面は 3 つ。2 つ目の面から盤が 5×5 になる）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと（1 つ目の面をクリアした。クリアのタイルは金色にしない）の m.bubble.tile_mode は true、m.bubble.size_up_mode は false。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) とし、m._input(down) をしたあと（2 つ目の面に進んだ）の m.session.level_index は 1、m.sound.played の中の "line" の数（m.sound.played.count("line")）は 0。続けて m.tick_size_up(0.7) をしたあと（0.6 秒待って、お知らせが出た）の m.bubble.size_up_mode は true、m.bubble.text は m.size_up_tile_text() と同じ文、m.bubble.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)、m.sound.played の中の "line" の数は 1、m.sound.vibrations の最後は 60、m.sound.vibration_amplitudes の最後は 0.6（誤差 0.001 まで）。'
  target: m.tick_size_up
  expect:
  - 'm.bubble.size_up_mode'
  - 'm.sound.vibrations'
extra_items: 0
keep:
  files: [core/rules.gd, game/session.gd, scenes/board_view.gd, scenes/sound.gd]
  other:
  - 'scenes/message_bubble.gd の show_tile・clear_tile_box・show_panel・step_blink は変えない'
  - 'scenes/main.gd の size_up_wait・size_up_age の決まりと、面のクリアのタイルの出し方は変えない'
changing_tests: []
unchanged_tests:
  - 'test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age'
  - 'test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja'
  - 'test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en'
  - 'test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja'
  - 'test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en'
  - 'test/cr/test_cr_1076.gd::test_show_tile_and_clear_text'
  - 'test/cr/test_cr_1076.gd::test_main_integration_tile'
  - 'test/cr/test_cr_1095.gd::test_cr_1095_clear_tile_box_style'
  - 'test/cr/test_cr_1141.gd::test_cr_1141_clear_text_restores_normal_style'
  - 'test/cr/test_pixel_1023.gd::test_pixel_1023_bubble_is_orange_with_white_text'
  - 'test/cr/test_cr_1091.gd::test_cr_1091_step_blink_panel_mode'
  - 'test/cr/test_cr_1086.gd::test_cr_1086_show_panel_and_clear_text_style'
  - 'test/cr/test_cr_1135.gd::test_cr_1135_bubble_geometry_and_font'
  - 'test/cr/test_pixel_1023.gd::test_pixel_1023_fit_font_size'
```

## CR（CR-1188-1188v.local.md）

# CR-1188: 盤が大きくなる面のお知らせを派手にする

## 変えること
- scenes/message_bubble.gd に const SIZE_UP_BG := Color8(255, 215, 64)、const SIZE_UP_BORDER := Color8(230, 110, 20)、const SIZE_UP_POP_TIME := 0.3、var size_up_mode: bool = false、var pop_age: float = -1.0 を足す。func size_up_box() -> StyleBoxFlat を足し、地の色 SIZE_UP_BG・縁の色 SIZE_UP_BORDER・縁の太さ 8（4 辺とも）・角の丸み 24（4 隅とも）・anti_aliasing true の新しい StyleBoxFlat を返す。
- scenes/message_bubble.gd に func show_size_up(text_to_show: String, center: Vector2) -> void を足す。show_tile(text_to_show, center) を呼んだあと、size_up_mode = true とし、"normal" の stylebox を size_up_box() に、"font_size" を fit_font_size(text_to_show, TILE_SIZE, 52, 36) にし、pivot_offset = TILE_SIZE / 2.0、pop_age = 0.0、scale = Vector2.ONE とする。
- scenes/message_bubble.gd に static func size_up_pop_scale(age: float) -> float を足す（age が 0 未満か SIZE_UP_POP_TIME 以上なら 1.0、ほかは 1.0 + 0.25 * sin(PI * age / SIZE_UP_POP_TIME)）。func step_pop(delta: float) -> void を足す（pop_age が 0 未満なら何もしない。pop_age に delta を足し、SIZE_UP_POP_TIME 以上になったら pop_age = -1.0・scale = Vector2.ONE、ほかは scale = Vector2(s, s)。s は size_up_pop_scale(pop_age)）。func _process で step_blink(delta) のあとに step_pop(delta) を呼ぶ。func clear_text で、tile_mode を戻す前に、size_up_mode が true なら size_up_mode = false・pop_age = -1.0・scale = Vector2.ONE・"font_size" を FONT_SIZE にする。
- scenes/main.gd の func tick_size_up で、bubble.show_tile(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) の代わりに bubble.show_size_up(size_up_tile_text(), board_view.position + board_view.board_rect().get_center()) を呼び、続けて sound.play_sfx("line") と sound.vibrate(60, 0.6) を呼ぶ。

## 変えないこと
- `README.md`、`SPEC.md`、`addons/`、`assets/`、`core/`、`data/`、`export_presets.cfg`、`game/`、`project.godot`、`scenes/app.gd`、`scenes/app.tscn`、`scenes/board_view.gd`、`scenes/button_style.gd`、`scenes/clear_effect.gd`、`scenes/cloud_store.gd`、`scenes/hud.gd`、`scenes/input_mapper.gd`、`scenes/licenses_panel.gd`、`scenes/main.tscn`、`scenes/rules_label.gd`、`scenes/rules_pages.gd`、`scenes/rules_panel.gd`、`scenes/sound.gd`、`scenes/space_bg.gd`、`scenes/splash_screen.gd`、`scenes/title_screen.gd`、`test/`、`tools/`、`.autedev/`
- `scenes/message_bubble.gd`: `BOX`、`ButtonStyle`、`TILE_OFFSET_Y`、`TILE_FONT_COLOR`、`PANEL_BOX`、`PANEL_FONT_SIZE`、`TEXT_MAX_FONT_SIZE`、`TEXT_MIN_FONT_SIZE`、`PANEL_MAX_FONT_SIZE`、`PANEL_MIN_FONT_SIZE`、`panel_mode`、`blink_time`、`normal_position`、`show_text`、`text_height`、`show_panel`、`set_normal_font_look`、`panel_alpha`、`clear_tile_box`
- `scenes/main.gd`: `tutorial_finished`、`title_requested`、`Session`、`InputMapper`、`RulesLabelScript`、`Tutorial`、`SpaceBg`、`Rules`、`Sound`、`TutorialSteps`、`SessionSave`、`RulesPanel`、`ProgressStore`、`HELP_TEXT`、`CLEARED_TEXT`、`ALL_CLEARED_TEXT`、`LOGO_GAP`、`rules_label`、`tutorial`、`start_with_tutorial`、`space_bg`、`language`、`last_snapshot`、`last_conflicts`、`last_dead`、`last_dead_marks`、`last_lines`、`save_path`、`progress_store`、`clear_effect`、`last_status`、`last_tutorial_status`、`safe_top`、`hud`、`base_positions`、`rules_panel`、`title_logo`、`size_up_wait`、`size_up_age`、`current_store`、`save_progress`、`apply_screen_layout`、`place_title_logo`、`part_rects`、`to_board_pos`、`is_on_board`、`on_apply`、`start_tutorial`、`end_tutorial`、`open_rules`、`rules_is_open`、`is_tutorial`、`tutorial_input`、`show_help`、`help_text`、`dead_marks_text`、`size_up_text`、`is_last_level`、`cleared_text`、`go_back`、`on_title_requested`、`tutorial_accepts_cell`、`hint_text`、`update_music`
- 依頼の欄: core/rules.gd は変えない（依頼の欄）。
- 依頼の欄: game/session.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/board_view.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/sound.gd は変えない（依頼の欄）。
- 依頼の欄: scenes/message_bubble.gd の show_tile・clear_tile_box・show_panel・step_blink は変えない（依頼の欄）
- 依頼の欄: scenes/main.gd の size_up_wait・size_up_age の決まりと、面のクリアのタイルの出し方は変えない（依頼の欄）

## 新しい宣言
- `res://scenes/message_bubble.gd` に足す（既存のファイルに足す）
  - `const SIZE_UP_BG := Color8(255, 215, 64)`
  - `const SIZE_UP_BORDER := Color8(230, 110, 20)`
  - `const SIZE_UP_POP_TIME := 0.3`
  - `var size_up_mode: bool = false`
  - `var pop_age: float = -1.0`
  - `func size_up_box() -> StyleBoxFlat`
  - `func show_size_up(text_to_show: String, center: Vector2) -> void`
  - `static func size_up_pop_scale(age: float) -> float`
  - `func step_pop(delta: float) -> void`

## 自動で確かめること
1. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.tile_mode は true、b.text は "THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START"。b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色）、border_color は Color8(230, 110, 20)（濃い橙）、border_width_top は 8。b.get_theme_font_size("font_size") は b.fit_font_size("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", B.TILE_SIZE, 52, 36) と同じ値。b.pivot_offset は Vector2(450, 80)（タイルの真ん中）、b.pop_age は 0.0（誤差 0.001 まで）。
2. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とする。B.size_up_pop_scale(0.15) は 1.25、B.size_up_pop_scale(0.075) は 1.1768、B.size_up_pop_scale(0.0) は 1.0、B.size_up_pop_scale(0.3) は 1.0、B.size_up_pop_scale(-1.0) は 1.0（どれも誤差 0.001 まで。0.15 秒でいちばん大きく 1.25 倍になり、0.3 秒で元の大きさに戻る）。
3. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。続けて b.step_pop(0.15) をしたあとの b.pop_age は 0.15（誤差 0.001 まで）、b.scale は Vector2(1.25, 1.25)（誤差 0.001 まで）。続けて b.step_pop(0.2) をしたあと（0.3 秒を過ぎた）の b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)。
4. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色の札が出た）。続けて b.step_pop(0.1) をしたあとの b.scale は Vector2(1.2165, 1.2165)（誤差 0.001 まで。弾んでいる途中）。続けて b.clear_text() をしたあとの b.size_up_mode は false、b.tile_mode は false、b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)、b.get_theme_stylebox("normal") は b.normal_box と同じもの、b.get_theme_font_size("font_size") は B.FONT_SIZE と同じ値。
5. テストの関数の中で var Level = load("res://game/level.gd")、var SessionScript = load("res://game/session.gd") とし、var l1 = Level.new() に l1.parse({"id": 1, "width": 4, "height": 4, "target": 4, "regions": [[0, 0, 0, 0], [0, 0, 0, 2], [3, 1, 1, 1], [1, 1, 1, 1]]})、var l2 = Level.new() に l2.parse({"id": 2, "width": 5, "height": 5, "target": 5, "regions": [[0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3], [4, 4, 4, 4, 4]]})、var l3 = Level.new() に l2 と同じ形で id だけ 3 の parse をする（面は 3 つ。2 つ目の面から盤が 5×5 になる）。var m = load("res://scenes/main.tscn").instantiate() として m.session = SessionScript.new([l1, l2, l3]) とし、add_child_autofree(m) をして await wait_frames(2) をする。m.session.solve_now() をしたあと（1 つ目の面をクリアした。クリアのタイルは金色にしない）の m.bubble.tile_mode は true、m.bubble.size_up_mode は false。var down = InputEventScreenTouch.new() として down.index = 0、down.pressed = true、down.position = Vector2(540, 300) とし、m._input(down) をしたあと（2 つ目の面に進んだ）の m.session.level_index は 1、m.sound.played の中の "line" の数（m.sound.played.count("line")）は 0。続けて m.tick_size_up(0.7) をしたあと（0.6 秒待って、お知らせが出た）の m.bubble.size_up_mode は true、m.bubble.text は m.size_up_tile_text() と同じ文、m.bubble.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)、m.sound.played の中の "line" の数は 1、m.sound.vibrations の最後は 60、m.sound.vibration_amplitudes の最後は 0.6（誤差 0.001 まで）。
6. 既存のテストがすべて合格する。

## 人が確かめること
- Pixel で 4×4 の最後の面をクリアして次の面に進み、盤が見えてから金色のお知らせがぽんと弾んで出て、音と短い振動が来ることを見る。面のクリアのタイル（ピンク）と見分けられるかを見る。

## 変わらない既存のテスト
- test/cr/test_cr_1178.gd::test_cr_1178_size_up_wait_and_age — 0.6 秒待って出る・0.8 秒は消さない決まりは変えない。tile_mode と文は今と同じ
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_ja — 字の大きさの上限 52 で、日本語のお知らせは 2 行に収まる（get_line_count は 2）
- test/cr/test_cr_1172.gd::test_cr_1172_size_up_tile_en — お知らせの文は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_ja — size_up_text は変えない
- test/cr/test_cr_1167.gd::test_cr_1167_size_up_text_en — 同じ
- test/cr/test_cr_1076.gd::test_show_tile_and_clear_text — show_tile は変えない
- test/cr/test_cr_1076.gd::test_main_integration_tile — 面のクリアのタイルは show_tile で出す
- test/cr/test_cr_1095.gd::test_cr_1095_clear_tile_box_style — ピンクのタイル（clear_tile_box）は変えない
- test/cr/test_cr_1141.gd::test_cr_1141_clear_text_restores_normal_style — clear_text は、金色のタイルのときだけ戻すものを足す。ふつうの吹き出しの戻し方は変えない
- test/cr/test_pixel_1023.gd::test_pixel_1023_bubble_is_orange_with_white_text — 吹き出しの色は変えない
- test/cr/test_cr_1091.gd::test_cr_1091_step_blink_panel_mode — パネルの点滅（step_blink）は変えない
- test/cr/test_cr_1086.gd::test_cr_1086_show_panel_and_clear_text_style — パネルは変えない
- test/cr/test_cr_1135.gd::test_cr_1135_bubble_geometry_and_font — 金色の札を出さない道（show_panel と clear_text）だけを見ている。clear_text に足す戻しは size_up_mode が true のときだけ動くので、位置・大きさ・字の大きさ 36・48・36 は変わらない
- test/cr/test_pixel_1023.gd::test_pixel_1023_fit_font_size — fit_font_size と text_height は変えない（show_size_up は fit_font_size を呼ぶだけ）。show_text・show_panel の字の大きさと枠の大きさも変わらない

## 対象の候補
- edit: `scenes/message_bubble.gd`、`scenes/main.gd`
