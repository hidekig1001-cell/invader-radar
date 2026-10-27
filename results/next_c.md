2 本: 岩の NG（数字の無い岩も同じ版）は、直しを当てると既存のテストは全部通り、直しなしでは probe の 4 件だけが落ちる／お知らせから「タップではじめる」を消す直しは、当てると変わる既存のテスト 3 件だけが落ち、直しなしでは probe の 2 件だけが落ちる

# C 組の調べと依頼の下書き（2026-10-27 21:0x、Invader Radar31 の頼み、brief briefs/ir_next_c.md @9c92621）

土台は main 8111de3。アプリのコードは書き換えていない（main・ほかの branch には触っていない）。

## 置いたもの（drafts/）
- 1 本目（本命）: req_rock_ng_both.txt・req_rock_ng_both_probe.gd・try_rock_ng_both_patch.py
  - 決め D-20261027-2103＝A（数字の無い岩も同じ）を受けて、数字付きの岩だけの版（req_rock_ng.txt ほか）は作っていない。
- 2 本目: req_size_up_no_tap.txt・req_size_up_no_tap_probe.gd・try_size_up_no_tap_patch.py

## 当て試し（Godot 4.7.2、main 8111de3 の写し 4 つ、GUT で test/unit・test/cr を流す。test/integration の dir は main に無い）

| 写し | 直し | 全部 | 落ちたテスト | Script Error |
|---|---|---|---|---|
| n0 | なし（probe 2 本だけ足す） | 764 + probe 6 | probe 6 件だけ（岩 4・お知らせ 2）。岩の probe は rock_ng が無い Invalid call | 岩の probe で 1 |
| nr | 岩の NG だけ | 764 + 6 | お知らせの probe 2 件だけ | 0 |
| ns | お知らせだけ | 764 + 6 | test_cr_1172_size_up_tile_ja・test_cr_1172_size_up_tile_en・test_cr_1178_size_up_wait_and_age と岩の probe 4 件 | 岩の probe で 1 |
| nb | 両方 | 764 + 6 | test_cr_1172_size_up_tile_ja・test_cr_1172_size_up_tile_en・test_cr_1178_size_up_wait_and_age の 3 件だけ（依頼に「変わる既存のテスト」として書いたもの） | 0 |

## 調べて分かったこと
- 1 本目
  - 音の名前は "wrong"（sound.gd の sfx_for）。まちがいのときの振動は _refresh の vibrate(250, 0.3)。同じ値で出す。
  - 入れ場所は main.gd の入力の所（_on_touch_up の "tap"）にした。Session は盤と手数の決まりだけを持ち、音と振動は main.gd が出しているので、Session に信号を足すより筋が通る。新しい関数 rock_ng(x, y) -> bool にまとめて、probe から直接も確かめられるようにした。
  - ダブルタップ: InputMapper.classify は 1 回目のタッチを "tap" としてすぐ返し、300ms 以内に同じマスの 2 回目が来ると "double_tap" を返す。だからダブルタップの身ぶりは必ず先に "tap" を通る。"tap" の所だけで鳴らすと、ダブルタップでも 1 回だけ鳴る（probe の項目 3 で確かめた）。"double_tap" でも鳴らすと 2 回鳴る。
  - なぞり（swipe）は呼ばない（項目 4）。チュートリアル中は rock_ng が false を返し、チュートリアルの入力は前に返るので鳴らない。
  - 最初の _refresh は何も鳴らさない（1189）ので、probe の played・vibrations は [] から始まる。
- 2 本目
  - ja は "この面からはマスが %d×%d になるよ。\nがんばって！  タップではじめる"、en は "THE BOARD IS %dx%d FROM HERE.\nGOOD LUCK!  TAP TO START"（scenes/main.gd 545・547 行）。終わりの 2 つの空白ごと消す。
  - 字の大きさ: 消したあとも show_size_up の字は上限の 52 で、2 行（get_line_count 2）。見た目の字の大きさは変わらない（短くなるだけ）。
  - size_up_text（札でない文）・クリアの札・0.8 秒の決まりは触らない。

## 迷った点
- NG を Session ではなく main.gd の入力の所で出すことにした。Session.tap の戻り値で弾いたかを返す作りもあるが、Session の決まりと既存のテストを動かさない方を選んだ。
- ダブルタップは「1 回目のタップで鳴る 1 回だけ」にした。2 回鳴らす方が「ダブルタップでも NG」と分かりやすいかもしれないが、振動が 250ms を 2 回続けるのは強すぎると見た。
- なぞりが岩を通るときは鳴らさない（依頼の 1・2 はタップ・ダブルタップだけ）。なぞりの始まりが岩のマスでも鳴らない。
- 前に保存した盤で岩のマスに宇宙人や × が残っていても、タップすれば鳴る（盤は変えない）。それで困る場面は見当たらなかった。
- R-RED（宣言の中身を空にした版が表明で落ちること）: rock_ng を「return false」だけにすると項目 1〜3 が落ちる。項目 4 も先頭の ["wrong"] で落ちる。
- 2 本目の英語の札も同じに消した（ユーザーの原文は日本語の札だけ）。
