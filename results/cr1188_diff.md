差分 OK

# InvaderRadar改修1188 の差分（cr/1188-safe-apply 225a588 と main 9193cdf）の見立て

merge-base は 9193cdf。commit は 225a588 の 1 つ。依頼と CR は branch review/cr1188-r0p の briefs/ir_cr1188_r0p.md、R3' は review/cr1188-r3p-2 と読み比べた。ユーザーの判断 D-20261027-1615＝A のとおりで読んだ。

## 1. 変わったファイル
- 変わったのは scenes/main.gd（+3 −1）、scenes/message_bubble.gd（+50）、test/cr/test_cr_1188.gd（新しい）だけ。
- ほかのファイル・既存のテストは変わっていない。.uid も無い。
- test_cr_1188.gd は、R3'（2 回目）の材料（review/cr1188-r3p-2 の briefs/ir_cr1188_r3p-2.md）と 1 文字も違わない。

## 2. scenes/message_bubble.gd — 依頼どおり
- 定数 SIZE_UP_BG = Color8(255, 215, 64)、SIZE_UP_BORDER = Color8(230, 110, 20)、SIZE_UP_POP_TIME = 0.3 と、変数 size_up_mode = false、pop_age = -1.0 を足した。
- size_up_box: 地 SIZE_UP_BG、縁 SIZE_UP_BORDER、縁の太さ 8（set_border_width_all）、角 24（set_corner_radius_all）、anti_aliasing true の新しい StyleBoxFlat。依頼どおり。
- show_size_up: 次の順。字の上限 52・下限 36 で依頼どおり。
  1. show_tile
  2. size_up_mode = true
  3. "normal" を size_up_box()
  4. "font_size" を fit_font_size(text, TILE_SIZE, 52, 36)
  5. pivot_offset = TILE_SIZE / 2.0
  6. pop_age = 0.0
  7. scale = Vector2.ONE
- size_up_pop_scale（0 未満か 0.3 以上なら 1.0、ほかは 1 + 0.25 sin(π age / 0.3)）と step_pop（pop_age < 0 なら何もしない、0.3 以上で -1.0・等倍、ほかは s 倍）は、依頼の式のまま。
- _process: step_blink(delta) の直後に step_pop(delta)。
- clear_text: tile_mode の枝の中、tile_mode = false の前で、size_up_mode なら次の 4 つを戻す。
  - size_up_mode = false
  - pop_age = -1.0
  - scale = Vector2.ONE
  - font_size を FONT_SIZE
  - 依頼の「tile_mode を戻す前に」のとおり。
- show_tile・clear_tile_box・show_panel・step_blink・BOX（吹き出しの大きさ）・fit_font_size・text_height は変わっていない。

## 3. scenes/main.gd — 依頼どおり
- tick_size_up の bubble.show_tile(…) を bubble.show_size_up(…) に替え、続けて sound.play_sfx("line")・sound.vibrate(60, 0.6) を足した所だけ。
- 変わっていないもの:
  - size_up_wait・size_up_age の決まり（0.6 秒・0.8 秒）。
  - 面のクリアのタイル（_refresh の show_tile(cleared_text(), …)）。
  - 1187 の last_dead_marks。
  - 1184 の line の決まり（last_lines・new_lines・flash_lines）。
- お知らせの line は _refresh を通らず直に鳴らすので、last_lines や flash_lines には影響しない。

## 4. 下書きの try_notice_patch.py との比べ
- 中身（定数・変数・関数の本体・_process・main.gd の 3 行）は同じ。
- 違いは 2 つだけで、どちらも依頼の決まりから外れていない。
  - clear_text の戻しの置き場所:
    - 下書きは `if tile_mode:` の前に独立した `if size_up_mode:` を置き、branch は `if tile_mode:` の中・tile_mode = false の前に置く。
    - size_up_mode が true になるのは show_size_up だけで、show_size_up は必ず show_tile を先に呼ぶ（tile_mode = true）。tile_mode を false にするのは clear_text だけ（main の grep で 1 か所）。
    - そのため、size_up_mode が true のときは必ず tile_mode も true で、どちらの置き方でも結果は同じ。
  - 関数の置き場所: 下書きは show_panel の前、branch はファイルの末尾。コメントの有無も違う。

## 5. 見た目の見立て
- 画面の端からのはみ出し:
  - 札は 900×160 で、pivot_offset が札の真ん中なので、真ん中を軸に大きくなる。
  - お知らせは盤の真ん中に出る。盤が横の真ん中（x = 540）にあるとき、1.25 倍で札の幅は 1125 になり、左右とも約 22 px 画面（1080 幅）の外に出る。
  - 幅が 1080 を超えるのは s > 1.2、つまり sin > 0.8 のあいだで、0.3 秒のうち約 0.12 秒（0.09 秒〜0.21 秒）だけ。
  - 字は札の内側（縁 8 の内、幅 約 884 で折り返す）に収まる大きさなので、1.25 倍で最大 約 1105 幅になる。いちばん長い行が横いっぱいなら、ほんの一瞬、行の端が画面の端に掛かりうる。
  - 依頼の数（900・1.25 倍）のとおりで、依頼から外れた所ではないので NG にはしない。
  - Pixel の確かめで「弾むときに左右の縁が切れて見える」のが気になれば、いちばん大きい倍率を 1.18 前後（900 × 1.18 ≒ 1062）にすれば収まる。
- 止まるか:
  - step_pop は pop_age が 0 未満なら何もせず返る。0.3 秒を過ぎると pop_age = -1.0・scale = 1 にして、それ以後は scale を書かない。
  - scale を変えるのは弾みの 0.3 秒だけなので、弾みが終われば描き直しは続かない。_process は今までどおり毎フレーム呼ばれるが、step_pop の中は比べ 1 回だけ。
- 細かい所（NG ではない）:
  - clear_text は pivot_offset を元に戻さない。等倍に戻すので見た目には効かない。
  - 次に show_size_up を出すとき、pivot_offset をまた入れ直す。
