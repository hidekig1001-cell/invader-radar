# クラウドへの依頼: InvaderRadar改修1179 の差分を読む（2026-10-27 03:2x、Invader Radar29）

branch cr/1179-safe-apply（b92aadd）と、その土台の main e6cf4ca（v1.86-cr1177）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1179-r0p の briefs/ir_cr1179_r0p.md。アプリのコードは書き換えない。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。

見ること:
1. 変わったのは scenes/sound.gd・scenes/main.gd と、test/cr/test_cr_1179.gd（と dead.wav を使うならその読み込み）だけか。変わる既存のテストは「なし」なので、既存のテストのファイルが書き換わっていないか。
2. sound.gd: const SFX_DEAD（dead.wav の preload）と play_sfx の match の "dead"。ほかの効果音・vibrate を変えていないか。
3. main.gd: var last_dead、_refresh で curr_dead（チュートリアルでなく Rules.dead_marks が空でない）、sfx_name が "mark" で last_snapshot が空でなく last_dead が false で curr_dead が true のとき "dead" に、last_conflicts を入れ直すところで last_dead = curr_dead、play_sfx の後に "dead" なら vibrate(120)。依頼どおりか、余計な変更が無いか。
4. 依頼に無い副作用（place の 30 ms 振動、チュートリアル・ヒント・ANSWER・面の切り替え・最初の _refresh）を壊していないか。swipe（CHECK 5）や面の切り替え（CHECK 6）で last_dead の入れ直しが正しく働くか。
5. 今の main は 05834fd（v1.87-cr1178。InvaderRadar改修1178 で main.gd の _refresh・_process・_on_touch_down にお知らせの待ちが入った）。cr/1179-safe-apply を 05834fd に merge したとき、main.gd でぶつかる所や、1178 の size_up_wait の動きと 1179 の音・振動がおかしく絡む所が無いかを見る（git merge を手元で試すのはよいが、push しない）。

終わりの条件: 結果を branch review/cr1179-diff のファイル results/cr1179_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。5 の merge の見立ても書く。main・ほかの branch には触らない。
