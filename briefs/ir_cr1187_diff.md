# クラウドへの依頼: InvaderRadar改修1187 の差分を読む（2026-10-27 16:5x、Invader Radar30）

branch cr/1187-safe-apply（69e4c97）と、その土台の main 0ae3435（v1.94-cr1185）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1187-r0p の briefs/ir_cr1187_r0p.md（R0' OK）、R3' は review/cr1187-r3p の results/cr1187_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
ユーザーの判断 D-20261027-1607＝A（× だけの組が新しくできるたびに鳴らす）。ユーザー「振動自体はすごく良い」ので、振動の長さと強さは変えない。
同じ時に InvaderRadar改修1186（game/session.gd に is_radar、数字の岩を弾く）の run も流れている。1187 は scenes/main.gd だけを直すので、ぶつからない見込み。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd・test/cr/test_cr_1187.gd（新しい）・test/cr/test_cr_1179.gd・test/cr/test_cr_1182.gd（依頼の「変わる既存のテスト」の所だけ）か。ほかのファイル・ほかの既存のテストは変わっていないか。test_cr_1187.gd は R3' で読んだものと同じか（R3' で見つけた迷いの英語のコメントも含めて）。
2. scenes/main.gd: last_dead が last_dead_marks に替わり、_refresh の curr_dead_marks（チュートリアルなら []）、「last_dead_marks に無いマスが 1 つでもあり、sfx_name が "mark" か "clear"、last_snapshot が空でなければ "dead"」、last_dead_marks = curr_dead_marks、start_tutorial・end_tutorial の入れ直しが依頼どおりか。振動の長さと強さ（place 30・mark 15/0.4・dead 250/0.3・wrong 250/0.3）・line の決まり（last_lines・curr_lines・new_lines・flash_lines）・1178 のお知らせの待ちを変えていないか。
3. 下書きの try_bug_dead_new_group_patch.py と比べて、違いがあれば、それが依頼の決まりから外れていないか。
4. 効果音の順（level_clear > wrong > hint > dead > line > clear > place > mark）が保たれているか。dead と line が同じ手で起きるとき（× だけの組と、宇宙人 1 つと × の組が同時にできる手）に dead になるか。
5. 写真の盤（レベル 6、橙の区域と桃の区域が順に × だけになる）の流れで、2 つとも鳴る見立てか。

終わりの条件: 結果を branch review/cr1187-diff のファイル results/cr1187_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
