# クラウドへの依頼: InvaderRadar改修1185 の差分を読む（2026-10-27 14:5x、Invader Radar30）

branch cr/1185-safe-apply（d1fc956）と、その土台の main 61433f2（v1.93-cr1184）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1185-r0p の briefs/ir_cr1185_r0p.md（R0' OK）、R3' は review/cr1185-r3p の results/cr1185_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/board_view.gd・scenes/main.gd・test/cr/test_cr_1185.gd（新しい）だけか。scenes/sound.gd・core/・game/・既存のテストは変わっていないか。test_cr_1185.gd は R3' で読んだものと同じか。
2. scenes/board_view.gd: LINE_FLASH_TIME := 0.3・flashes・flash_cells・flash_start（-1.0）、flash_lines（flash_cells を [] にしてから組ごとに flashes へ cells を足し、まだ無いマスだけ flash_cells へ、flash_start = pop_clock、queue_redraw）、flash_alpha（flash_start が 0 未満・t が 0 未満か 1 以上なら 0.0、ほかは 0.5 * (1.0 - t)）が依頼どおりか。_draw の光が「5. Draw Highlight/Darkening」の前で tile_rect のタイルの形・Color(1, 1, 1, 値) か。_process の queue_redraw の条件が依頼どおりか。宇宙人の弾み（piece_pop）・マスと × の描き方を変えていないか。
3. scenes/main.gd: sound.play_sfx(sfx_name) のあとに sfx_name が "line" なら board_view.flash_lines(new_lines) を呼ぶ所だけが足されたか。効果音・振動・dead と line の決まりを変えていないか。
4. 下書きの try_line_patch.py の flash() と比べて、違いがあれば、それが依頼の決まりから外れていないか。
5. 描画の重さ（光っている 0.3 秒の間だけ毎フレーム描き直し、そのあと止まるか）と、光が宇宙人・× の上に重なって見づらくならないか（白の不透明度 0.5 から）の見立て。

終わりの条件: 結果を branch review/cr1185-diff のファイル results/cr1185_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
