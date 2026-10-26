直した

# 手触り 2 本目・音の依頼（drafts/req_line_sound.txt）の既存のテストの欄を、main b50af7e（v1.91-cr1182）の実際のテストに合わせた（10/27、クラウドセッション）

- branch: draft/line
- 直したところ: 本文の「変わる既存のテスト」「変わらない既存のテスト」と、YAML の changing_tests・unchanged_tests。
- 変えていないところ: 本文の頭・変えること・確かめる項目・YAML のほかの欄。

## line に替わる手がある既存のテスト（調べ方）
- main b50af7e の写しに `try_line_patch.py sound`（rules ＋ sound）を当てた。
- 「sfx_name を line に替えた手」で、しるしを出す 1 行を写しの中だけに足して GUT を流した。どのテストのどの関数に line の手があるかを数えた。
- line の手があったのは 3 つの関数だけ:

| テスト | line の手 | 表明は変わるか |
|---|---|---|
| test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien | m.session.tap(3, 0)（行 0 が宇宙人 1 つと × 3 つでそろう） | **変わる**。mark が line になり、× の 15 の振動が 1 つ減る |
| test/cr/test_cr_1026.gd::test_main_cleared_text_ja | 答えの宇宙人を置く途中で、1 マスの区域 (3, 1)・(0, 2) がそろう | 変わらない（見ているのは面のクリアと吹き出しの文） |
| test/cr/test_cr_1043.gd::test_double_tap_places_piece | 1 マスの区域 (3, 1) に宇宙人を置く | 変わらない（見ているのは盤の状態） |

- test_cr_1180・test_cr_1181・test_cr_1182 には、line の手が無かった。
  - 1180・1182 は、宇宙人が無いか 1 つと × 1 つだけ。
  - 1181 は × が無い。
  - チュートリアルの盤の手は、line を鳴らさない決まり。

## 対応表（前の下書きの名前 → 実際の名前）

| 前の下書き | main b50af7e | 欄 |
|---|---|---|
| test_cr_1179.gd::test_no_dead_on_row_with_alien | test_cr_1179.gd::test_cr_1179_main_dead_with_alien | 変わる |
| test_cr_1179.gd::test_dead_on_region_filled | test_cr_1179.gd::test_cr_1179_main_dead_transition | 変わらない |
| test_cr_1179.gd::test_dead_again_after_back_to_empty | test_cr_1179.gd::test_cr_1179_main_dead_retrigger | 変わらない |
| test_cr_1180.gd::test_mark_vibrates_small | test_cr_1180.gd::test_cr_1180_main_vibrate_on_place_and_mark | 変わらない |
| test_cr_1180.gd::test_no_vibrate_on_remove | test_cr_1180.gd::test_cr_1180_main_vibrate_sequence | 変わらない |
| test_cr_1181.gd::test_wrong_vibrates_long_weak | test_cr_1181.gd::test_cr_1181_diagonal_collision_vibration | 変わらない |
| test_cr_1182.gd::test_dead_vibrates_long_weak | test_cr_1182.gd::test_cr_1182_dead_vibration_duration_and_amplitude | 変わらない |

「変わらない既存のテスト」に足したもの:
- test_cr_1179 の残り 5 つ（sound_dead_sfx・main_dead_swipe・main_dead_next_level・main_dead_initial_state・main_dead_tutorial）
- test_cr_1180 の残り 4 つ（sound_vibrate_amplitude・main_vibrate_on_swipe・main_vibrate_in_tutorial・main_vibrate_on_dead_transition）
- test_cr_1181 の残り 2 つ（vertical_collision_and_removal_vibration・tutorial_collision_vibration）
- test_cr_1182 の残り 2 つ（dead_vibration_on_swipe・dead_vibration_not_retriggered）
- 上の表の test_cr_1026::test_main_cleared_text_ja と test_cr_1043::test_double_tap_places_piece

全部で 33 個。

## 「変わる既存のテスト」の新しい文（全文）
```
- test/cr/test_cr_1179.gd::test_cr_1179_main_dead_with_alien — m.session.tap(3, 0) のあと（行 0 が宇宙人 1 つと × 3 つでそろい、効果音が mark ではなく line になるので、× の 15 の振動が 1 つ減る）の assert_eq(m.sound.vibrations, [30, 15, 15, 15]) は assert_eq(m.sound.vibrations, [30, 15, 15]) に、m.session.tap(3, 1) のあとの assert_eq(m.sound.vibrations, [30, 15, 15, 15, 15, 250]) は assert_eq(m.sound.vibrations, [30, 15, 15, 15, 250]) に変わる
```
- 前の文の終わりの「（CR-1179・CR-1180・CR-1182 の後の main のテストの形。CR を作る前に、そのときの表明を書き写す）」は、実際の表明に合わせたので消した。
- 実際のテスト（b50af7e の 64 行目と 69 行目）の表明は `[30, 15, 15, 15]` と `[30, 15, 15, 15, 15, 250]` で、上の A と一字一句同じ。

## テストの結果（Godot 4.7.2、main b50af7e の写し、GUT を test/unit と test/cr で流した）

| 写し | 当てたもの | 結果 |
|---|---|---|
| 1 | `try_line_patch.py sound`（rules ＋ sound）と、rules・sound の probe | 734 件のうち、落ちたのは 1 件で、test_cr_1179_main_dead_with_alien（`[30, 15, 15] != [30, 15, 15, 15]` と `[30, 15, 15, 15, 250] != [30, 15, 15, 15, 15, 250]`）。「変わる既存のテスト」のとおり。rules の 5 件・sound の 10 件の probe は通った。SCRIPT ERROR は 0 件 |
| 1 ＋ 書き換え | 上の「A は B に変わる」をそのテストに当てたもの | 734 件すべて通った |

- try_line_patch.py は、b50af7e では前提の直し（1179〜1182）がもう入っているので、それらを当てずに rules と sound だけを当てた。
