# クラウドへの依頼: InvaderRadar改修1184 の差分を読む（2026-10-27 11:2x、Invader Radar30）

branch cr/1184-safe-apply（40cd1d7）と、その土台の main 5f52a46（v1.92-cr1183）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1184-r0p の briefs/ir_cr1184_r0p.md（R0' OK）、R3' は review/cr1184-r3p の results/cr1184_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
ユーザーの判断 D-20261027-0545＝A: 答えとは比べない。line の手では × の 15 ms・宇宙人の 30 ms の振動を出さない。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/sound.gd・scenes/main.gd・test/cr/test_cr_1184.gd（新しい）・test/cr/test_cr_1179.gd（test_cr_1179_main_dead_with_alien の振動の並び 2 か所だけ）か。core/rules.gd・game/・scenes/board_view.gd・ほかの既存のテストは変わっていないか。test_cr_1184.gd は R3' で読んだものと同じか。
2. scenes/sound.gd: const SFX_LINE（place.wav と同じフォルダの line.wav）と play_sfx の "line" だけが足されたか。Sound.sfx_for・振動（vibrate）を変えていないか。
3. scenes/main.gd: var last_lines、_refresh の curr_lines（チュートリアルなら []）・new_lines・sfx_name が clear・place・mark で last_snapshot が空でなく new_lines が空でないときだけ line に替える所が、dead に替える所のあとにあるか。last_lines = curr_lines が last_dead = curr_dead のあとにあるか。dead の決まり・振動の長さと強さを変えていないか。line の手で × の 15 ms・宇宙人の 30 ms の振動が出ない（振動は効果音が mark・place のときだけ）ことが今のコードで成り立つか。
4. 下書きの try_line_patch.py の sound() と比べて、違いがあれば、それが依頼の決まりから外れていないか。
5. 次の InvaderRadar改修1185（光。draft/line の drafts/req_line_flash.txt、main.gd では sound.play_sfx(sfx_name) のあとに sfx_name が "line" なら board_view.flash_lines(new_lines)）が、この差分の上にそのまま当たるか（new_lines の名前と置き場所）。

終わりの条件: 結果を branch review/cr1184-diff のファイル results/cr1184_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
