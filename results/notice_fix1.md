直した: R-C28 「変わらない既存のテスト」に 2 つを足した／R-RED 項目 4 の初めで、金色の札が出て弾むことを先に確かめる形にした

# InvaderRadar改修1188（お知らせを金色の札に、案 A）の依頼の下書きの直し（10/27、クラウドセッション）

- branch: draft/notice
- 直したファイル:
  - drafts/req_notice.txt（本文と YAML）
  - drafts/req_notice_probe.gd（CHECK 4）
- try_notice_patch.py は直していない（直しの中身は変わらない）。
- origin の decision を D-20261027-1615 にした（ユーザーの判断＝A）。

## 1. R-C28: 「変わらない既存のテスト」に足した 2 つ（本文と YAML の unchanged_tests の両方）
```
- test/cr/test_cr_1135.gd::test_cr_1135_bubble_geometry_and_font — 金色の札を出さない道（show_panel と clear_text）だけを見ている。clear_text に足す戻しは size_up_mode が true のときだけ動くので、位置・大きさ・字の大きさ 36・48・36 は変わらない
- test/cr/test_pixel_1023.gd::test_pixel_1023_fit_font_size — fit_font_size と text_height は変えない（show_size_up は fit_font_size を呼ぶだけ）。show_text・show_panel の字の大きさと枠の大きさも変わらない
```
- 読んだこと:
  - test_cr_1135 は、`show_panel("STEP")` → `clear_text()` の道で、位置 (40, 262)・大きさ (1000, 192)・字の大きさ 36 → 48 → 36 を見ている。
    - 案 A は clear_text の中に「size_up_mode が true なら戻す」を足すだけ。このテストでは size_up_mode が false のまま動くので（＝金色の札を出していないので）、値は変わらない。
  - test_pixel_1023_fit_font_size は、fit_font_size・text_height・show_text・show_panel・clear_text の字の大きさと枠を見ている。案 A はどれも書き換えない。
- 変わらないに挙げたテストは 12 個から 14 個になった。

## 2. R-RED: 確かめる項目 4 の直し
- 前の項目 4: show_size_up → step_pop(0.1) → clear_text のあと、size_up_mode が false、tile_mode が false、pop_age が -1.0、scale が (1, 1)、stylebox が normal_box、字の大きさが FONT_SIZE、だけを見ていた。
  - 中身の無い版（show_size_up・step_pop が何もしない）では、もともとその値なので、全部通ってしまった。
- 直した項目 4（全文）:
```
4. テストの関数の中で var B = load("res://scenes/message_bubble.gd") とし、var b = B.new() を add_child_autofree(b) する。b.show_size_up("THE BOARD IS 5x5 FROM HERE.\nGOOD LUCK!  TAP TO START", Vector2(540, 980)) をする（英語のお知らせの文。\n は改行）。そのあとの b.size_up_mode は true、b.get_theme_stylebox("normal") の bg_color は Color8(255, 215, 64)（金色の札が出た）。続けて b.step_pop(0.1) をしたあとの b.scale は Vector2(1.2165, 1.2165)（誤差 0.001 まで。弾んでいる途中）。続けて b.clear_text() をしたあとの b.size_up_mode は false、b.tile_mode は false、b.pop_age は -1.0（誤差 0.001 まで）、b.scale は Vector2(1, 1)、b.get_theme_stylebox("normal") は b.normal_box と同じもの、b.get_theme_font_size("font_size") は B.FONT_SIZE と同じ値。
```
- 1.2165 は 1.0 + 0.25 × sin(π × 0.1 / 0.3) ＝ 1.21651 から（誤差 0.001）。
- YAML の checks の R4 の text も同じ文にし、expect に `b.get_theme_stylebox("normal")` を足した。
- probe の CHECK 4 には、clear_text の前に 3 つの表明を足した:
  - `assert_true(b.size_up_mode)`
  - `assert_eq(b.get_theme_stylebox("normal").bg_color, Color8(255, 215, 64))`
  - `assert_lt(b.scale.distance_to(Vector2(1.2165, 1.2165)), 0.001)`

## 3. 当て試し（Godot 4.7.2、main 0ae3435 の写し、GUT を test/unit と test/cr で流した。probe は test/cr/test_cr_1188.gd に置いた）

| 写し | 当てたもの | 結果 |
|---|---|---|
| 直しあり | try_notice_patch.py ＋ probe | 743 件すべて通った。SCRIPT ERROR は 0 件。test_cr_1135・test_pixel_1023 も通った |
| 直しなし | probe だけ | probe の 5 件だけが落ちた（まだ無い関数を呼ぶので実行時エラー） |
| 中身の無い版をまねたもの | message_bubble.gd に新しい宣言だけを足した版（下） | probe の 5 件がすべて落ち、どれも表明で落ちた |

- 中身の無い版をまねたものの作り:
  - const 3 つと var 2 つは宣言どおり。
  - size_up_box は null、size_up_pop_scale は 0.0 を返す。show_size_up・step_pop は何もしない。
  - main.gd と clear_text は今のまま（直していない）。
- 中身の無い版をまねたものでの落ち方:
  - CHECK 4 は、size_up_mode が true でない、地の色がピンクではなく吹き出しの色、scale が 1.2165 でない、の 3 か所の表明で落ちた（前は全部通っていた）。
  - CHECK 5 は、表明（line の数 0≠1、地の色）で落ちたほかに、実行時エラーが 1 つあった。`m.sound.vibrations[-1]` が、振動が 1 つも無い（空の並び）ために読めないため。前の検査では CHECK 5 は R-RED に挙がっていないので、変えていない。
    - 気になるなら、項目 5 の「m.sound.vibrations の最後は 60」を「m.sound.vibrations の中の 60 の数（m.sound.vibrations.count(60)）は 1」に替えると、中身の無い版でも表明だけで落ちる。
