# クラウドへの依頼: InvaderRadar改修1188 の差分を読む（2026-10-27 18:1x、Invader Radar30）

branch cr/1188-safe-apply（225a588）と、その土台の main 9193cdf（v1.96-cr1186）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1188-r0p の briefs/ir_cr1188_r0p.md（R0' OK）、R3' は review/cr1188-r3p-2 の results/cr1188_r3p_2.md（2 回目で OK、1 回目は差し戻し）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
ユーザーの判断 D-20261027-1615＝A（金色の札がぽんと弾む）。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは scenes/message_bubble.gd・scenes/main.gd・test/cr/test_cr_1188.gd（新しい）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1188.gd は R3'（2 回目）で読んだものと同じか。
2. scenes/message_bubble.gd: 定数・変数・size_up_box・show_size_up（字の上限 52・下限 36）・size_up_pop_scale・step_pop・_process の呼び出し・clear_text の戻しが依頼どおりか。show_tile・clear_tile_box・show_panel・step_blink・吹き出しの大きさを変えていないか。
3. scenes/main.gd: tick_size_up で show_tile を show_size_up に替え、play_sfx("line")・vibrate(60, 0.6) を足した所だけか。size_up_wait・size_up_age の決まり・面のクリアのタイル・1187 の last_dead_marks・1184 の line の決まりを変えていないか。
4. 下書きの try_notice_patch.py と比べて、違いがあれば、それが依頼の決まりから外れていないか。
5. 見た目の見立て: 金色の札が弾むあいだに、札の字や縁が画面の端からはみ出さないか（1.25 倍、札は 900×160、画面は 1080 幅）。弾みが終わったら止まるか（毎フレームの描き直しが続かないか）。

終わりの条件: 結果を branch review/cr1188-diff のファイル results/cr1188_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
