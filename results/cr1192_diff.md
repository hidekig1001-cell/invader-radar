差分 OK

InvaderRadar改修1192（× だけの組の判定で岩のマスを先に飛ばす）の差分の読み。branch cr/1192-safe-apply（d89ab06）と、その土台の main 46fc619 を比べた。2026-10-27、クラウドセッション。

## 1. 変わったファイル — OK
- 差分は core/rules.gd（+9・-6）と test/cr/test_cr_1192.gd（新しい、+85）の 2 つだけ。ほかのファイル・既存のテストは変わっていない。.uid の新しいファイルも無い。
- test_cr_1192.gd は、R3' の brief（review/cr1192-r3p の briefs/ir_cr1192_r3p.md）の「== tests/test_cr_1192.gd」の中身と一字一句同じだった（機械で比べた。2137 文字）。

## 2. core/rules.gd — OK
- dead_marks の行（`for x in range(width)`）・列（`for y in range(height)`）・区域（区域の番号ごとの 2 重のループ）の 3 か所で、同じ形の直しをしている。
  - `elif is_asteroid.call(x, y) or is_radar_cell.call(x, y): continue` を消す。
  - その代わりに、`var state = board_state.state_at(x, y)` の前に `if is_asteroid.call(x, y) or is_radar_cell.call(x, y): continue` を足す。
  - 区域では、`if level.region_at(x, y) != r_id: continue` のあとに足している。
- 状態の見方は変わっていない。宇宙人なら `has_alien = true` で break、× なら `marks_in_row`／`marks_in_col`／`marks_in_region` に足す、空なら `all_marks = false` で break。
- 終わりの並べ替え（`result.sort_custom`。y の小さい順、同じなら x の小さい順）も変わっていない。
- filled_lines・conflicts・is_solved・radar_*、ほかの関数は変わっていない（差分の行は dead_marks の中だけ）。

## 3. 今の面での × の色と dead の音 — 変わらない
- 2 つの決まりの違いが出るのは、岩（小惑星・レーダー）のマスに宇宙人がある盤だけ。
  - 岩のマスの × は、前も後も数えない（前の作りでも、× の判定は岩の判定より後だった）。
  - 岩でないマスは、前と後で同じ判定を通る。
- 今の面では、岩のマスに宇宙人は置かれない:
  - CR-1186（main 9193cdf から）で、Session.tap・double_tap・swipe は岩のマスを弾く。小惑星は前から弾いていた。
  - ヒント（apply_hint）・solve_now・最初の宇宙人（given）は Solver の答えを使う。1186 の差分の読み（review/cr1186-diff）で、数字付きの岩のある 275 の面の答えを全部出して調べたが、岩のマスに宇宙人のある答えは 0 だった。小惑星は Solver が飛ばす。
- そのため、今の面では、dead_marks の値は変わらない。それを使う次のものも変わらない:
  - board_view.mark_color_at（× の赤）
  - main.gd の dead の音と振動（last_dead_marks）
  - help_text の吹き出し
- 変わるのは、1186 より前に保存した盤で、岩のマスに宇宙人が残っている場合だけ。そのときは、その行・列・区域も × だけの組として赤くなり、dead が鳴る（依頼の意図どおり、filled_lines と合う）。
- 既存のテストの mark_color_at・dead の音のもの（test_cr_1130・1137・1173・1174・1179・1184・1187・pixel_1023）は、下の当て試しですべて通った。

## 4. 下書きの try_dead_marks_order_patch.py（draft/next-a）との違い
- 置き換えの中身は同じ（岩の continue を状態の判定の前に移す。3 か所）。
- 違いは、差分が足した if の後に空行（字下げのタブだけの行）を 1 行入れていること。働きは同じで、依頼の決まりから外れていない。

## テストの結果（Godot 4.7.2、GUT を test/unit と test/cr で流した）

| 写し | 結果 |
|---|---|
| cr/1192-safe-apply（土台 46fc619） | 752 件すべて通った。SCRIPT ERROR は 0 件 |
| main 2f8272f（1189 の入った今の main）＋ 1192 の差分（git apply で当てた） | 755 件すべて通った。SCRIPT ERROR は 0 件。1189 とぶつからない |
