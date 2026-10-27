差分 NG: board_view.gd の flash_lines が最初に flashes.clear() をしていて、依頼の「flashes に光らせた組を順に記録する（[] にするのは flash_cells だけ）」から外れている

InvaderRadar改修1185（光）の差分の読み。branch cr/1185-safe-apply（d1fc956）と、その土台の main 61433f2 を比べた。2026-10-27、クラウドセッション。

## NG の中身
- 依頼（と CR）の決まり:
  - 「変えること」の 2 つ目: 「flash_cells を [] にしてから、lines の組ごとに flashes に組の "cells" を足し、flash_cells に組のマスを（まだ無いものだけ）足す」。
  - 頭の段落: 「光らせた組のマスの並びを board_view の flashes に順に記録する」。
  - [] にするのは flash_cells だけで、flashes は手をまたいで足していく記録。
- 差分の flash_lines（scenes/board_view.gd の終わり）:
  ```
  func flash_lines(lines: Array) -> void:
  	flashes.clear()
  	flash_cells.clear()
  	...
  ```
  `flashes.clear()` があるので、flashes には最後の line の手の組しか残らない。
- 確かめた。d1fc956 の写しで、2 回続けて line の手をする見本のテストを流した（branch には入れていない）:
  - 手: 宇宙人 (0, 0)、× (1, 0)・(2, 0)・(3, 0) で行 0、続けて × (0, 1)・(1, 1) で区域 0。
  - 結果: flashes は `[[(0, 0), (1, 0), (0, 1), (1, 1)]]` の 1 組だけで、行 0 の組が消えていた。依頼どおりなら 2 組。
- 確かめる項目 1〜4（test_cr_1185）は、どれも line の手が 1 回だけ。そのため、この違いは今のテストでは見つからない。R3' の OK とは食い違わない。
- 見た目（光るマスと明るさ）には影響しない。flashes は記録（テストから読むための並び）だけで、描くのは flash_cells。それでも依頼の決まりから外れているので NG とする。

## 直し方（scenes/board_view.gd の flash_lines の 1 行を消す）
```
 func flash_lines(lines: Array) -> void:
-	flashes.clear()
 	flash_cells.clear()
```
- `flash_cells.clear()` は、依頼の「flash_cells を [] にしてから」と同じ（`= []` と同じ働き）。そのまま残す。
- この 1 行を消しても、test_cr_1185 の 4 つはそのまま通る見込み。
  - どれも、line の手が 1 回だけの盤（新しい main ごとの board_view）で flashes を見ている。
  - CHECK 4 の dead の手では flash_lines が呼ばれないので、flashes は []。そのあとの line の手で [区域 0] になる。
- 依頼の側を直すなら（同じ取り違えを避けるため）、「変えること」の 2 つ目を次の文にする:
```
- scenes/board_view.gd に func flash_lines(lines: Array) -> void を足す。flash_cells だけを [] にし（flashes は [] にしない。flashes は手をまたいで記録を足していく）、lines の組ごとに flashes の後ろに組の "cells" を 1 つ足し、flash_cells に組のマスを（まだ無いものだけ）足す。flash_start = pop_clock とし、queue_redraw() を呼ぶ。func flash_alpha(now: float) -> float を足す。flash_start が 0 未満なら 0.0、t = (now - flash_start) / LINE_FLASH_TIME が 0 未満か 1 以上なら 0.0、ほかは 0.5 * (1.0 - t) を返す。
```
- 確かめる項目に、2 回目の line の手のあとに flashes が 2 組になることを足す手もある（例: 項目 2 の続きで m.session.tap(0, 1)、m.session.tap(1, 1) をしたあとの m.board_view.flashes は [行 0 のマス, 区域 0 のマス]）。

## 見ることごとの見立て
1. **変わったファイル — OK**
   - 差分は scenes/board_view.gd（+35）・scenes/main.gd（+2）・test/cr/test_cr_1185.gd（新しい、+155）の 3 つだけ。
   - scenes/sound.gd・core/・game/・既存のテストは変わっていない。.uid の新しいファイルも無い。
   - test_cr_1185.gd は、R3' の brief（review/cr1185-r3p の briefs/ir_cr1185_r3p.md）の「== tests/test_cr_1185.gd」の中身と一字一句同じだった（機械で比べた。4484 文字）。
2. **scenes/board_view.gd — flash_lines の 1 行（上の NG）のほかは依頼どおり**
   - 宣言: LINE_FLASH_TIME := 0.3、flashes: Array = []、flash_cells: Array = []、flash_start: float = -1.0 は、pop_clock の次に足してある。
   - flash_lines:
     - 組ごとに `flashes.append(cells)`。
     - まだ無いマスだけ `flash_cells.append(cell)`（`cell in flash_cells` で確かめる）。
     - `flash_start = pop_clock`、`queue_redraw()`。
     - ここまでは依頼どおり（`flashes.clear()` を除く）。
   - flash_alpha: flash_start が 0 未満なら 0.0。t が 0 未満か 1 以上なら 0.0。ほかは 0.5 * (1.0 - t)。依頼どおり。
   - _draw: マスの中身（× と宇宙人）を描くループのあと、「# 5. Draw Highlight/Darkening (CR-1022)」の前に足してある。flash_alpha(pop_clock) が 0 より大きければ、flash_cells のマスごとに、tile_rect と radius で Color(1, 1, 1, fa) の角丸の四角を描く。依頼どおり。
   - _process: 弾みの判定のあとに `if flash_start >= 0.0 and pop_clock - flash_start < LINE_FLASH_TIME + delta: needs_redraw = true`。依頼どおり。
   - 宇宙人の弾み（piece_pop_scale・piece_pop_start・PIECE_POP_TIME）と、マス・× の描き方は変わっていない。
3. **scenes/main.gd — OK**
   - 足したのは、`sound.play_sfx(sfx_name)` の後ろの振動の if/elif の並びのあとの 2 行 `if sfx_name == "line": board_view.flash_lines(new_lines)` だけ。play_sfx と同じ `if sfx_name != "":` の中にある。
   - 効果音・振動・dead と line の決まりは変わっていない。
4. **下書きの try_line_patch.py の flash() との違い**
   - flash_lines の初め: 下書きは `flash_cells = []` だけ。差分は `flashes.clear()` と `flash_cells.clear()`。flashes を空にするのは決まりから外れる（上の NG）。flash_cells.clear() は同じ働き。
   - flash_lines・flash_alpha の置き場所: 下書きは _process の前、差分はファイルの終わり。働きは同じ。
   - _draw の変数名: 下書きは flash_a・c、差分は fa・cell・t_r。働きは同じ。
   - main.gd の呼び出しの置き場所: 下書きは play_sfx の直後、差分は振動の if/elif の並びのあと。どちらも同じ `if sfx_name != "":` の中で、同じ手で 1 回だけ呼ばれる。働きは同じ。
5. **描画の重さと見え方の見立て**
   - 重さ:
     - _process は、光り始めから LINE_FLASH_TIME + delta（0.3 秒と 1 フレーム）のあいだだけ、毎フレーム queue_redraw を出す。60 fps で約 19 フレーム。そのあと止まる。
     - 最後の 1 フレームで flash_alpha が 0 になった盤が描かれ、光が消える。弾みの仕組みと同じ書き方で、止まらずに回り続けることは無い。
     - 光っているあいだの _draw は、盤を全部描き直して、そろったマス（4×4 なら 4〜7 マス）の四角を足すだけ。重さは弾みと同じくらいで、問題ない。
   - 見え方:
     - 光は × と宇宙人の上に描くので、光り始めは白の不透明度 0.5 で × と宇宙人の絵も白っぽくなる。0.15 秒で 0.25、0.3 秒で 0 まで下がるので、一瞬「ぱっと白くなって戻る」見え方になる見込み。
     - 黄色など明るい区域では、白が見えにくいかもしれない。
     - 見づらければ、次のどちらかを Pixel で比べて決めるのがよい。どちらも別の CR。
       - 光をマスの中身の前（タイルの上・× と宇宙人の下）に描く。
       - 最初の明るさを 0.35 くらいに下げる。
     - 人が確かめること（Pixel で見る）の中で見てほしい。

## テストの結果（Godot 4.7.2、d1fc956 の写し、GUT を test/unit と test/cr で流した）
- 既存のテストと test_cr_1185 の 738 件は、すべて通った。SCRIPT ERROR は 0 件。
- 上の見本のテスト（2 回の line の手で flashes が 2 組か）だけが落ちた（`[1] expected to equal [2]`）。
