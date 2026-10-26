# クラウドへの依頼: InvaderRadar改修1178 の差分を読む（2026-10-27 01:3x、Invader Radar28）

branch cr/1178-safe-apply と main（e6cf4ca）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1178-r0p-2 の briefs/ir_cr1178b_r0p.md。アプリのコードは書き換えない。

見ること:
1. 変わったのは scenes/main.gd と、test/cr/test_cr_1178.gd・test/cr/test_cr_1172.gd だけか。
2. main.gd: size_up_wait・size_up_age・tick_size_up の 3 つの宣言、_refresh で show_tile の代わりに size_up_wait = 0.6、_process の最初の return の後・session.tick の前で tick_size_up(delta)、_on_touch_down で待つ間の return と 0.8 秒より前の return。依頼どおりか、余計な変更（お知らせの文・クリアのタイル・ほかの関数）が無いか。
3. 依頼に無い副作用（チュートリアル・ヒント・ANSWER の流れ）を壊していないか。

終わりの条件: 結果を branch review/cr1178-diff のファイル results/cr1178_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
