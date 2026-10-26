# クラウドへの依頼: InvaderRadar改修1182 の差分を読む（2026-10-27 05:4x、Invader Radar29）

branch cr/1182-safe-apply と、その土台の main 0f865a6（v1.90-cr1181）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1182-r0p-2 の briefs/ir_cr1182_r0p2.md、R3' は review/cr1182-r3p-2 の results/cr1182_r3p_2.md（OK、1 回目は差し戻し）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd と、test/cr/test_cr_1182.gd（新しい）・test/cr/test_cr_1179.gd・test/cr/test_cr_1180.gd（書き直し）だけか。テストは R3'（2 回目）で読んだものと同じか（test_cr_1179_main_dead_swipe に強さの表明が足されていないか）。
2. main.gd: _refresh の dead の手の vibrate(120) を vibrate(250, 0.3) に替えただけか。place（30）・mark（15, 0.4）・wrong（250, 0.3、1181）の振動、dead を鳴らす決まり（last_dead・curr_dead）、1178 のお知らせの待ちを変えていないか。
3. 依頼に無い副作用（dead にならない手で 250 が出てしまわないか、スワイプの dead が 1 回だけか）。

終わりの条件: 結果を branch review/cr1182-diff のファイル results/cr1182_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
