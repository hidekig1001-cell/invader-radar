差分 OK

# InvaderRadar改修1190 の差分（cr/1190-safe-apply 6341fe5 と main 46fc619）の見立て

merge-base は 46fc619。commit は 6341fe5 の 1 つ。依頼と CR は branch review/cr1190-r0p の briefs/ir_cr1190_r0p.md、R3' は review/cr1190-r3p-2 と読み比べた。main はその後 2f8272f（1189、scenes/main.gd）に進んだが、1190 は game/level.gd だけなので、46fc619 を土台に読んだ。

## 1. 変わったファイル
- 変わったのは game/level.gd（+16）と test/cr/test_cr_1190.gd（新しい、+87）だけ。
- ほかのファイル・既存のテストは変わっていない。.uid も無い。
- test_cr_1190.gd は、R3'（2 回目）の材料と 1 文字も違わない。CHECK 3 は値まるごとの assert_eq の形で、CHECK 2 の迷いのコメントもそのまま。

## 2. game/level.gd — 依頼どおり
- 足したのは parse の中の 1 か所だけ。asteroids・radar を読んで `if ast == null or rad == null: return false` を通ったあと、id・width・height・regions を入れる前に次の 3 段をする。
  1. 局所の Grid g の番号を辞書に集める。
  2. keys() を sort() して小さい順に並べ、番号 → 0, 1, 2, … の対応表 remap を作る。
  3. g の全部のマスを remap の番号に入れ直す。
- 番号の大小の並び: 小さい順に並べた位置を新しい番号にするので、大小の並びは変わらない（例: 0・2・5・7 → 0・1・2・3）。
- false の筋:
  - 形が違う・数が合わないときの return false は、どれも詰め直しより前。
  - 詰め直しは局所の g の中だけで、メンバ（regions など）に入れるのはその後。
  - そのため、false のときに Level の中身は何も変わらない（今までと同じ）。
- region_at・region_count・to_dict・_read_cells・parse_radar・write_radar、asteroids・radar の読み方は変わっていない。to_dict は詰め直したあとの Grid をそのまま書く（R3' の CHECK 1 の期待値どおり）。

## 3. 今の面で何も変えないか・重さ
- 今の面の番号は、どれも 0 から続いている。
  - Python で 46fc619 の data/ と game/（level_pack.gd の固定の 10 面を含む）にある regions を全部調べた（14 個）。
  - 前の調べで test/ の中の面の辞書も全部調べてある。
  - 作る面（level_maker.gd の grow_regions）は、答えの行 i のマスに番号 i を置いて広げるので、0〜size-1 が続く。
- 番号が 0, 1, …, n-1 と続いていれば、小さい順に並べた位置はその番号そのものなので、remap は番号をそのまま返す。詰め直しても Grid の値は 1 つも変わらない。
- 重さ:
  - 面を 1 回読むごとに、盤のマスを 2 回回す（集めると入れ直し）。辞書の出し入れはマスの数だけで、並べ替えは区域の数（1 辺のマスの数、10 前後）だけ。
  - 10×10 でも 200 回ほどの簡単な処理で、parse は面を読むとき（立ち上げ・面の切り替え・読み直し・先読み）にしか呼ばれない。目に見えて遅くなることは無い。

## 4. 下書きの try_region_gaps_patch.py（draft/next-b）との比べ
- 結果は同じ。違いは書き方と置き場所だけで、依頼の決まりから外れていない。
  - 置き場所:
    - 下書きは、regions を Grid に入れた直後（asteroids・radar を読む前）に詰め直す。
    - branch は、asteroids・radar を読んで false の筋を通ったあとに詰め直す。
    - どちらも局所の g の中なので、false のときに何も残らない点は同じ。
    - branch の方が、false になる面で無駄な詰め直しをしない分だけ少しよい。
  - 書き方: 下書きは Array に集めて has と find。branch は Dictionary に集めて keys().sort() と対応表。
    - 番号の数が少ないのでどちらも軽いが、branch の対応表の方がマスごとの引きが速い。
    - 並べ方（小さい順）と結果の番号は同じ。
