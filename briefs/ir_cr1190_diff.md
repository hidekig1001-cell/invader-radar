# クラウドへの依頼: InvaderRadar改修1190 の差分を読む（2026-10-27 19:4x、Invader Radar31）

branch cr/1190-safe-apply と、その土台の main 46fc619（v1.97-cr1188）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1190-r0p の briefs/ir_cr1190_r0p.md（R0' OK）、R3' は review/cr1190-r3p-2 の results/cr1190_r3p_2.md（2 回目で OK、1 回目は期待値を分けた形で差し戻し）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
main は取り込みのあいだに 1189（scenes/main.gd の _refresh の 2 行）が入って進むが、1190 は game/level.gd だけなので、土台は 46fc619 で読んでよい。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは game/level.gd・test/cr/test_cr_1190.gd（新しい）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1190.gd は R3'（2 回目）で読んだものと同じか。
2. game/level.gd: parse で、regions を Grid に入れたあと、出てきた番号を小さい順に 0, 1, 2, … に詰め直して Grid に入れ直す所だけか。番号の大小の並びを変えないか。parse が false を返す筋で何も変えないか（途中で詰め直した値が残らないか）。region_at・region_count・to_dict・asteroids・radar の読み方を変えていないか。
3. 今の面（data の全部の面）で詰め直しが何も変えないか（番号が 0 から続いているので同じになるか）。読み込みが目に見えて遅くならないか（面ごとに一度だけ、盤のマスの数ほどの手間か）。
4. 下書きの try_region_gaps_patch.py（draft/next-b）と比べて、違いがあれば、それが依頼の決まりから外れていないか。

終わりの条件: 結果を branch review/cr1190-diff のファイル results/cr1190_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
