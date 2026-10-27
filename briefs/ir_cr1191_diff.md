# クラウドへの依頼: InvaderRadar改修1191 の差分を読む（2026-10-27 20:3x、Invader Radar31）

branch cr/1191-safe-apply と、その土台の main 8111de3（v2.00-cr1192）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1191-r0p-2 の briefs/ir_cr1191_r0p-2.md（R0' は 2 回目で OK）、R3' は review/cr1191-r3p の results/cr1191_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd・test/cr/test_cr_1191.gd（新しい）だけか。test/cr/test_cr_1187.gd を含め、ほかのファイル・既存のテストは変わっていないか。test_cr_1191.gd は R3' で読んだものと同じか。
2. scenes/main.gd: var last_dead の宣言と、値を入れる 3 行（_refresh・start_tutorial・end_tutorial）を消しただけか。end_tutorial の var marks と last_dead_marks = marks、1189 で足した _refresh の 2 行（last_snapshot が空なら sfx_name = ""）、last_dead_marks・last_lines・dead と line の決まりを変えていないか。
3. 消したあとに last_dead を読む所が main.gd・ほかの scenes・テスト・.autedev/shot.gd に残っていないか（残れば Parse Error になる）。
4. 下書きの try_cleanup_last_dead_patch.py（draft/next-a）の main.gd の部分と比べて、違いがあれば、それが依頼の決まりから外れていないか（下書きの test_cr_1187 のコメントの片づけは、今回は外したので無くてよい）。

終わりの条件: 結果を branch review/cr1191-diff のファイル results/cr1191_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
