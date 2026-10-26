差分 OK

# InvaderRadar改修1178 の差分（cr/1178-safe-apply d5feb6a と main e6cf4ca）の見立て

merge-base は e6cf4ca。commit は d5feb6a の 1 つ。依頼と CR は branch review/cr1178-r0p-2 の briefs/ir_cr1178b_r0p.md と読み比べた。

## 1. 変わったファイル
- scenes/main.gd（+20 −1）、test/cr/test_cr_1172.gd（+3）、test/cr/test_cr_1178.gd（新しい、+49）。
- ほかに test/cr/test_cr_1172.gd.uid（1 行の uid）が新しく入っている。Godot が .gd ごとに自動で作る印のファイルで、main でも古い test_cr_*.gd には .uid がある（1172・1174・1176・1177 には無い）。アプリの振る舞いもテストの中身も変えないので NG にはしない。取り込みで .uid を入れない決まりなら、外してよい。
- お知らせの文（size_up_text・size_up_tile_text）、scenes/message_bubble.gd、game/session.gd、scenes/board_view.gd、sound.gd ほかは変わっていない。

## 2. scenes/main.gd
- 宣言: var size_up_wait: float = 0.0 と var size_up_age: float = 0.0 を title_logo の後に足した。func tick_size_up(delta: float) -> void を _process の後に足した。依頼どおり（空行が 1 つ多いのは問題にしない）。
- _refresh: bubble.text == cleared_text() のとき clear_text の後、size_up_tile_text() が "" でなければ show_tile の代わりに size_up_wait = 0.6、"" なら show_help()。依頼どおり。クリアのタイル（cleared_text の show_tile）は変わっていない。
- tick_size_up:
  - size_up_wait > 0 なら delta を引き、0 以下で wait = 0・age = 0 にして show_tile(size_up_tile_text(), 盤の中心) をする。
  - そうでなく（wait は負にならないので「wait が 0 で」と同じ）tile_mode が true で bubble.text == size_up_tile_text() なら、age に delta を足す。
  - 依頼どおり。
- _process: 最初の return の判定の後、session.tick(delta) の前に tick_size_up(delta)。依頼どおり。
- _on_touch_down:
  - _stroke = [] の直後に「チュートリアルでなく size_up_wait > 0 なら return」。
  - お知らせのタイルを消す所で size_up_age < 0.8 なら return、そうでなければ今までどおり clear_text・show_help・return。
  - 依頼どおり。
- ほかの関数の変更は無い。

## 3. 依頼に無い副作用
- チュートリアル: _process はチュートリアル中に先に return するので tick_size_up は回らない。_on_touch_down の待つ間の return も「チュートリアルでなく」が付いている。_refresh の size_up_wait = 0.6 は bubble.text == cleared_text() の枝だけ。チュートリアルの流れは変わらない。
- ヒント・ANSWER: _on_hint・on_apply は変えていない。待つ 0.6 秒の間に盤のタップは return で無視されるので、盤の操作で吹き出しが変わることは無い。
  - 0.6 秒の間に HUD のヒントを押すと、ヒントの文が出た後に、時間がたってお知らせのタイルで上書きされうる。ヒントのマスの印は残る。
  - 依頼の作りの範囲の小さな縁の場合で、NG にはしない。気になるなら人の確かめで見る。
- ルール画面: 開いている間は _process が return するので待ちが止まり、閉じた後に続きから数える。害は無い。
- 新しいテスト test_cr_1178 と test_cr_1172 の書き直しは、R3'（3 回目、results/cr1178_r3p_3.md）で OK にしたものと同じ中身。
