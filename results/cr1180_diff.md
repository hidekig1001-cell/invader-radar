差分 OK

# InvaderRadar改修1180 の差分（cr/1180-safe-apply a94389a と main fd8c810）の見立て

merge-base は fd8c810。commit は a94389a の 1 つ。依頼と CR は branch review/cr1180-r0p-2 の briefs/ir_cr1180b_r0p.md、R3' は review/cr1180-r3p の results/cr1180_r3p.md と読み比べた。

## 1. 変わったファイル
- scenes/main.gd（+2）、scenes/sound.gd（+4 −2）。
- test/cr/test_cr_1180.gd（新しい）、test/cr/test_cr_1177.gd・test/cr/test_cr_1179.gd（書き直し）。
- 依頼に無いファイルとして、test/cr/test_cr_1177.gd.uid・test/cr/test_cr_1179.gd.uid（各 1 行）が新しく入っている。
  - CR-1178 のときの test_cr_1172.gd.uid と同じく、Godot が自動で作る印のファイル。振る舞いは変えないので NG にはしない。
  - 取り込みで .uid を入れない決まりなら外してよい。
- test_cr_1180.gd は、R3' の材料と 1 文字も違わない。
- test_cr_1177・test_cr_1179 の書き直しの −／+ 行も、R3' の材料と同じ（1177 の 30 行目のコメントの書き換えも含む。R3' に書いたとおり NG にはしない）。

## 2. sound.gd
- var vibration_amplitudes: Array = [] を vibrations の後に足した。
- func vibrate(ms: int) を func vibrate(ms: int, amplitude: float = -1.0) -> void に替えた。中身は次の順で、依頼どおり。
  1. vibrations.append(ms)
  2. vibration_amplitudes.append(amplitude)
  3. Input.vibrate_handheld(ms, amplitude)
- -1.0 は Godot の vibrate_handheld の amplitude の既定値と同じなので、vibrate(30)・vibrate(120) の振動は今までと変わらない。
- play_sfx、ほかの効果音、sfx_for、SFX_DEAD は変わっていない。

## 3. main.gd
- _refresh の play_sfx の後の if/elif に elif sfx_name == "mark": sound.vibrate(15, 0.4) を足しただけ。
  - "place" → vibrate(30)、"mark" → vibrate(15, 0.4)、"dead" → vibrate(120)。依頼どおり。
- dead を鳴らす決まり（curr_dead・last_dead と "mark" → "dead" の差し替え）は、if/elif の前にあって変わっていない。dead の手は sfx_name が "dead" になってから振動の分かれ道に来るので、15 は出ず 120 だけになる。
- 1178 のお知らせの待ち（size_up_wait・size_up_age・tick_size_up・_on_touch_down・_process）は変わっていない。
- そのほか、余計な変更は無い。

## 4. 依頼に無い副作用
fd8c810 の Sound.sfx_for で読んだ。sfx_for は level_clear > wrong > hint > clear（宇宙人が減る）> place > mark（× が増える）> "" の順。

- × を消す手: × の数が減るだけなので ""。振動しない。
- 宇宙人を取る手: "clear"。振動しない。
- 面の切り替え: 新しい盤は × が 0 なので ""（または level_clear などの先の音）。振動しない。
- チュートリアル: start_tutorial と end_tutorial で last_snapshot を入れ直すので、切り替えでは振動しない。チュートリアルの盤の × の手で 15 が出るのは依頼どおり。
- ヒント: "hint" が先なので 15 は出ない。
- ANSWER（on_apply → apply_hint）: 当てた結果が × を増やすだけの手なら、今でも効果音は "mark" なので 15 も出る。依頼の「sfx_for が mark を返す手」の決めのとおりで、問題にしない。
- 最初の _refresh: last_snapshot が空なので、× がある盤（宇宙人なし）を読み直して立ち上げると "mark" で 15 が 1 回出る。依頼の「変わる既存のテスト」（test_cr_1179_main_dead_initial_state の [15]）で決めてあるとおり。宇宙人がある盤では、今までどおり "place" の 30 が出る。
- スワイプ: _commit が 1 回なので 15 は 1 回（CHECK 4）。
