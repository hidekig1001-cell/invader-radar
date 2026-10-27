# クラウドへの依頼: InvaderRadar改修1193 の差分を読む（2026-10-27 22:xx、Invader Radar31）

branch cr/1193-safe-apply と、その土台の main 8111de3（v2.00-cr1192）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1193-r0p の briefs/ir_cr1193_r0p.md（R0' OK）、R3' は review/cr1193-r3p の results/cr1193_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
main はその後 1191（scenes/main.gd の last_dead の 4 行を消す）が入って 82eb05b（v2.01-cr1191）に進んだが、1193 の直しとは別の行なので、土台は 8111de3 で読んでよい。run の最後の commit は e26c432（22:13 pushed）。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd・test/cr/test_cr_1193.gd（新しい）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1193.gd は R3' で読んだものと同じか。
2. scenes/main.gd: 新しい func rock_ng(x, y) -> bool（チュートリアル中・session が null なら false、岩（is_radar・is_asteroid）なら play_sfx("wrong") と vibrate(250, 0.3) で true、盤・手数・元に戻すは変えない）と、入力の "tap" の所で rock_ng を呼ぶ所だけか。"double_tap"・"swipe" では呼ばないか。Session・sound.gd・input_mapper.gd・ほかの音と振動の決まりを変えていないか。
3. ダブルタップのとき、1 回目のタップで鳴ったあと、2 回目（double_tap）で盤に宇宙人が付かないか（今までどおり Session が岩を弾く）。岩でないマスのタップ・ダブルタップ・なぞりの音と振動が今までと同じか。
4. 下書きの try_rock_ng_both_patch.py（draft/next-c）と比べて、違いがあれば、それが依頼の決まりから外れていないか。

終わりの条件: 結果を branch review/cr1193-diff のファイル results/cr1193_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
