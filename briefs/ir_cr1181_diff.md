# クラウドへの依頼: InvaderRadar改修1181 の差分を読む（2026-10-27 05:1x、Invader Radar29）

branch cr/1181-safe-apply と、その土台の main a12daf1（v1.89-cr1180）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1181-r0p の briefs/ir_cr1181_r0p.md、R3' は review/cr1181-r3p の results/cr1181_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd と test/cr/test_cr_1181.gd（新しい）だけか。既存のテストは書き換わっていないか（依頼は「変わる既存のテスト: なし」）。test_cr_1181.gd は R3' で読んだものと同じか。
2. main.gd: _refresh の play_sfx の後で "wrong" なら vibrate(250, 0.3) を足しただけか。place（30）・mark（15, 0.4）・dead（120）の振動、dead を鳴らす決まり（last_dead・curr_dead）、1178 のお知らせの待ちを変えていないか。
3. 依頼に無い副作用（ぶつかった宇宙人を取る手・ヒント・ANSWER・面の切り替え・最初の _refresh で 250 が出てしまわないか。wrong と dead が同じ手で起きたときの振る舞い）。
4. 次に入る InvaderRadar改修1182（dead の手の vibrate(120) を vibrate(250, 0.3) に）と、main.gd の同じあたりでぶつからないかの見立て。

終わりの条件: 結果を branch review/cr1181-diff のファイル results/cr1181_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
