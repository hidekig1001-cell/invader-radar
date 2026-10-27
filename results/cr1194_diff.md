差分 OK

# InvaderRadar改修1194 の差分（cr/1194-safe-apply 4f001b3 と merge-base 8111de3）の見立て

merge-base は 8111de3（v2.00-cr1192。brief の見込みのとおり）。commit は 4f001b3 の 1 つ。依頼と CR は branch review/cr1194-r0p の briefs/ir_cr1194_r0p.md、R3' は review/cr1194-r3p と読み比べた。

## 1. 変わったファイル
- 変わったのは次のファイルだけ。ほかのファイルは変わっていない。
  - scenes/main.gd（2 行）
  - test/cr/test_cr_1194.gd（新しい）
  - test/cr/test_cr_1172.gd（3 行）
  - test/cr/test_cr_1178.gd（1 行）
  - test/cr/test_cr_1178.gd.uid（Godot の印。NG にしない）
- test_cr_1194.gd は、R3' の材料（review/cr1194-r3p の briefs/ir_cr1194_r3p.md）と 1 文字も違わない。
- test_cr_1172.gd・test_cr_1178.gd の差分は、R3' で読んだ書き直しと同じ。
  - 1172 の 27 行目・62 行目・63 行目、1178 の 39 行目の期待値だけ。表明の足し引きは無い。

## 2. scenes/main.gd — 依頼どおり
- size_up_tile_text の 2 つの return の文だけが変わった。
  - 日本語: "この面からはマスが %d×%d になるよ。\nがんばって！  タップではじめる" → "この面からはマスが %d×%d になるよ。\nがんばって！"。
  - 英語: "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!  TAP TO START" → "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!"。
- 終わりに空白は残っていない。R0' で書いた CR の「空白 1 つ」の写り違いは、実装に出ていない。
- 変わっていないもの:
  - size_up_tile_text の始めの `if size_up_text() == "": return ""` と幅 w の取り方。
  - size_up_text・cleared_text（クリアと全部クリアの札の文）。
  - tick_size_up（金色の札・line の音・60 ms・0.6 の振動）。
  - _on_touch_down の 0.8 秒の決まり。
  - scenes/message_bubble.gd（弾み・字の大きさ 52・36）。

## 3. 「タップではじめる」「TAP TO START」がほかに残っている所（依頼の範囲外、NG にしない）
branch の scenes・game・test を grep した。

- game/tutorial_steps.gd 47 行目: チュートリアルの終わりの英語の文 "WELL DONE! YOU ARE READY.\nTAP TO START."。お知らせの札ではなく、チュートリアルの文。
- scenes/rules_pages.gd 127 行目: ルールの頁のボタンの字 "はじめる"。「タップではじめる」とは別の、ボタンの名前。
- test/cr/test_cr_1188.gd 12・43・58 行目: 英語の文 "…GOOD LUCK!  TAP TO START" を、message_bubble の show_size_up に直に渡して金色の札の形を見ているテスト。size_up_tile_text を通らないので、この改修の後も通る（R0' で「変わらない既存のテスト」に入っている）。札の文の見本が古いままになるだけ。
- ヘルプの文（help_text）と、ほかの札（クリア・全部クリア）の文には、どちらの言葉も無い。

## 今の main との重なり
- main は 8111de3 の後に 1191（82eb05b、main.gd の last_dead の宣言と 3 行を消す）が入った。
- 取り込み中の 1193 は、main.gd の _on_touch_up の "tap" の枝と、ファイルの末尾に rock_ng を足す。
- 1194 が変えるのは size_up_tile_text の中の 2 行（main 8111de3 で 545・547 行目のあたり）で、どちらの改修の行とも離れている。git の当たりはぶつからない見込み。
