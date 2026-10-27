差分 OK

# InvaderRadar改修1193 の差分（cr/1193-safe-apply e26c432 と main 8111de3）の見立て

merge-base は 8111de3。commit は e26c432 の 1 つ。依頼と CR は branch review/cr1193-r0p の briefs/ir_cr1193_r0p.md、R3' は review/cr1193-r3p と読み比べた。main はその後 82eb05b（1191、main.gd の last_dead の 4 行）に進んだが、1193 が触る _on_touch_up の "tap" の所と末尾とは別の行なので、8111de3 を土台に読んだ。

## 1. 変わったファイル
- 変わったのは scenes/main.gd（+14）と test/cr/test_cr_1193.gd（新しい、+135）だけ。
- ほかのファイル・既存のテストは変わっていない。.uid も無い。
- test_cr_1193.gd は、R3' の材料（review/cr1193-r3p の briefs/ir_cr1193_r3p.md）と 1 文字も違わない。

## 2. scenes/main.gd — 依頼どおり
- 新しい func rock_ng(x: int, y: int) -> bool を、ファイルの末尾（update_music の後）に足した。
  - チュートリアル中なら false、session が null なら false。
  - session.is_radar(x, y) か session.is_asteroid(x, y) なら、sound.play_sfx("wrong") と sound.vibrate(250, 0.3) をして true。
  - それ以外は false。
  - 盤・手数・元に戻すの記録には触らない。
- _on_touch_up の match の "tap" で、チュートリアルでない枝の session.tap(c.x, c.y) の前に `if rock_ng(c.x, c.y): return` を足した。
- "double_tap"・"swipe" の枝では呼ばない（差分に無い）。
- 変わっていないもの:
  - Session（is_radar・is_asteroid・tap・double_tap・swipe）、sound.gd、input_mapper.gd。
  - _refresh の音と振動の決まり（1189 の最初の _refresh、dead・line）。

## 3. ダブルタップのとき・岩でないマス
- _on_touch_up は、`_prev_tap = r["tap_record"]` を match の前に入れる。そのため、"tap" の枝の途中で return しても、次のタップを InputMapper.classify がダブルタップと見る作りは変わらない。
- 岩をダブルタップすると、次のとおり、NG の音と振動はダブルタップで 1 回だけ。
  - 1 回目は "tap" → rock_ng が鳴らして return（session.tap は呼ばない）。
  - 2 回目は "double_tap" → session.double_tap(c.x, c.y)。Session が is_asteroid・is_radar（1186）で弾いて false を返し、盤も手数も変わらず changed も出ないので、_refresh も音も無い。
  - 宇宙人は付かない。
- 岩でないマスでは、rock_ng が false を返し、今までどおり session.tap・double_tap・swipe に進む。音と振動は _refresh の決まりのままで変わらない。
- チュートリアル中は rock_ng が false を返す。tap の枝もチュートリアルの枝で、rock_ng は通らない。
- 面のクリアの後・お知らせの待ちの間は、_on_touch_down が _stroke を空にして return する。_on_touch_up も最初に返るので、岩でも鳴らない（今までと同じ流れ）。

## 4. 下書きの try_rock_ng_both_patch.py（draft/next-c）との比べ
- rock_ng の決まり（チュートリアル・null で false、数字付きの岩と小惑星の両方で wrong と 250・0.3、true を返す）は同じ。
- 違いは 2 つで、どちらも依頼の決まりから外れていない。
  - 呼び方:
    - 下書きは `rock_ng(c.x, c.y)` の後に、そのまま `session.tap(c.x, c.y)` を呼ぶ。
    - branch は `if rock_ng(c.x, c.y): return` で、岩なら session.tap を呼ばない。
    - session.tap は岩なら盤を変えずに false を返す（changed も出ない）ので、結果は同じ。branch の方が無駄な呼び出しが無い。
  - 置き場所: 下書きは tutorial_accepts_cell の前（コメント付き）、branch はファイルの末尾（コメント無し）。振る舞いは同じ。
