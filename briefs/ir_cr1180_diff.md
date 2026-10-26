# クラウドへの依頼: InvaderRadar改修1180 の差分を読む（2026-10-27 04:3x、Invader Radar29）

branch cr/1180-safe-apply と、その土台の main fd8c810（v1.88-cr1179）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1180-r0p-2 の briefs/ir_cr1180b_r0p.md、R3' は review/cr1180-r3p の results/cr1180_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。

見ること:
1. 変わったのは scenes/sound.gd・scenes/main.gd と、test/cr/test_cr_1180.gd（新しい）・test/cr/test_cr_1177.gd・test/cr/test_cr_1179.gd（書き直し）だけか。書き直しは R3' で読んだものと同じか。
2. sound.gd: var vibration_amplitudes、func vibrate(ms: int, amplitude: float = -1.0)、vibrations と vibration_amplitudes に足してから Input.vibrate_handheld(ms, amplitude)。ほかの効果音・play_sfx を変えていないか。
3. main.gd: _refresh の play_sfx の後で、"place" は vibrate(30)、"dead" は vibrate(120)、"mark" は vibrate(15, 0.4)。dead を鳴らす決まり（last_dead・curr_dead）や 1178 のお知らせの待ち（size_up_wait など）を変えていないか。余計な変更が無いか。
4. 依頼に無い副作用（× を消す手・宇宙人を取る手・ヒント・ANSWER・チュートリアル・面の切り替え・最初の _refresh で 15 ms の振動が出てしまわないか）。

終わりの条件: 結果を branch review/cr1180-diff のファイル results/cr1180_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
