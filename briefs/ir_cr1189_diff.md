# クラウドへの依頼: InvaderRadar改修1189 の差分を読む（2026-10-27 19:2x、Invader Radar31）

branch cr/1189-safe-apply と、その土台の main 46fc619（v1.97-cr1188）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1189-r0p の briefs/ir_cr1189_r0p.md（R0' OK）、R3' は review/cr1189-r3p の results/cr1189_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/main.gd・test/cr/test_cr_1189.gd（新しい）・test/cr/test_cr_1179.gd（test_cr_1179_main_dead_initial_state の 2 か所）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1189.gd と test_cr_1179.gd の書き直しは R3' で読んだものと同じか。
2. scenes/main.gd: _refresh で、Sound.sfx_for で sfx_name を決めたすぐあとに、last_snapshot.is_empty() なら sfx_name を "" にする 1 か所だけか。last_snapshot・last_conflicts・last_dead_marks・last_lines の入れ直し、dead と line に替える決まり、振動の長さと強さ、チュートリアル、sound.gd の sfx_for を変えていないか。
3. sfx_name を "" にしたあと、line の光（board_view.flash_lines）・play_sfx・vibrate が最初の _refresh で呼ばれないか（呼ばれると立ち上げで鳴る・光る）。2 回目からの _refresh で今までどおり動くか。
4. 下書きの try_quiet_first_refresh_patch.py（draft/next-b）と比べて、違いがあれば、それが依頼の決まりから外れていないか。

終わりの条件: 結果を branch review/cr1189-diff のファイル results/cr1189_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
