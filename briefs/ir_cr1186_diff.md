# クラウドへの依頼: InvaderRadar改修1186 の差分を読む（2026-10-27 16:5x、Invader Radar30）

branch cr/1186-safe-apply（70d15bf）と、その土台の main 0ae3435（v1.94-cr1185）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1186-r0p の briefs/ir_cr1186_r0p.md（R0' OK）、R3' は review/cr1186-r3p の results/cr1186_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
いま main には InvaderRadar改修1187（scenes/main.gd だけ）を取り込んでいる。1186 は game/session.gd だけを直すので、ぶつからない見込み。1187 の後に 1186 を取り込む。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは game/session.gd・test/cr/test_cr_1186.gd（新しい）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1186.gd は R3' で読んだものと同じか。
2. game/session.gd: is_radar（level が null なら false、level.radar の [x, y, n] の x・y で比べる）、tap・double_tap の最初の判定に is_radar を足す（手数も増えない）、swipe の除くマスに is_radar を足す（除いたあと空なら false）が依頼どおりか。is_asteroid・apply_hint・undo など、ほかを変えていないか。
3. 下書きの try_bug_radar_block_patch.py と比べて、違いがあれば、それが依頼の決まりから外れていないか。
4. 1187 の入った main（scenes/main.gd の last_dead_marks）と合わせても、ぶつからないか・振る舞いが変わらないか。
5. ヒント・答え（apply_hint）がレーダーのマスに宇宙人を置く筋が残っていないか（前の調べでは無い見立て）。

終わりの条件: 結果を branch review/cr1186-diff のファイル results/cr1186_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
