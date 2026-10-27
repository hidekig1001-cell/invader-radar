差分 OK

InvaderRadar改修1189（立ち上げの最初の _refresh で音と振動を出さない）の差分の読み。branch cr/1189-safe-apply（7d512ab）と、その土台の main 46fc619 を比べた。2026-10-27、クラウドセッション。

## 1. 変わったファイル — OK
- 差分は次の 3 つだけ。ほかのファイル・既存のテストは変わっていない。.uid の新しいファイルも無い。
  - scenes/main.gd（+2）
  - test/cr/test_cr_1179.gd（2 行の書き換え）
  - test/cr/test_cr_1189.gd（新しい、+54）
- test_cr_1189.gd は、R3' の brief（review/cr1189-r3p の briefs/ir_cr1189_r3p.md）の「== tests/test_cr_1189.gd」の中身と一字一句同じだった（機械で比べた。1945 文字）。
- test_cr_1179.gd の書き直しは、R3' の brief の「既存のテストの書き直し」と同じ。test_cr_1179_main_dead_initial_state の 146 行 `[15]` は `[]` に、151 行 `[15, 250]` は `[250]` に。ほかの表明・手は変わっていない。

## 2. scenes/main.gd — OK
- 足したのは、_refresh の `var sfx_name = Sound.sfx_for(last_snapshot, curr_snapshot, last_conflicts, curr_conflicts)` のすぐあとの 2 行だけ:
  ```
  	if last_snapshot.is_empty():
  		sfx_name = ""
  ```
- 次のものは変わっていない（差分にこの 2 行のほか、main.gd の行は無い）:
  - last_snapshot・last_conflicts・last_dead・last_dead_marks・last_lines の入れ直し
  - dead に替える所（`(sfx_name == "mark" or sfx_name == "clear") and not last_snapshot.is_empty() and has_new_dead`）
  - line に替える所
  - 振動の長さと強さ
  - start_tutorial・end_tutorial
  - scenes/sound.gd の sfx_for

## 3. 最初の _refresh で鳴る・光る筋 — 無い。2 回目から今までどおり — OK
- sfx_name が "" になったあとの流れ:
  - dead に替える所は、sfx_name が "mark" か "clear" で、しかも last_snapshot が空でないときだけ。替わらない。
  - line に替える所は、sfx_name が "clear"・"place"・"mark" のどれかのときだけ。替わらない。
  - play_sfx・vibrate・board_view.flash_lines は、どれも `if sfx_name != "":` の中にある。呼ばれない。
- 最初の _refresh でも、last_dead_marks と last_lines には今の盤の値が入る。そのため、2 回目の手で「新しい組」と見なされるのは、その手で新しくできた組だけ（読み直した盤の組で鳴り直さない）。
- 確かめた: cr/1189-safe-apply の写しで、見本のテストを足して流した（branch には入れていない）。
  - 盤: 行 0 がそろった盤（(0, 0) に宇宙人、(1, 0)〜(3, 0) に ×）から立ち上げた。
  - 立ち上げ直後: played・vibrations・board_view.flashes がすべて []。
  - 続けて × を 2 つ付けて区域 0 をそろえた: played の最後は "line"、flashes は 1 組、vibrations は [15]（1 つ目の × の手の 15 だけ。line の手は振動しない）。
  - 今までどおり。

## 4. 下書きの try_quiet_first_refresh_patch.py（draft/next-b）との違い — OK
- 下書きは、2 行の前にコメント「# 最初の _refresh（立ち上げ・進み具合の読み直し）では効果音も振動も出さない」を付けていた。差分はコメント無し。働きは同じで、依頼の決まりから外れていない。

## テストの結果（Godot 4.7.2、cr/1189-safe-apply の写し、GUT を test/unit と test/cr で流した）
- 既存のテスト・test_cr_1189・上の見本のテストの 753 件は、すべて通った。SCRIPT ERROR は 0 件。
