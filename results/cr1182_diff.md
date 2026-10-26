差分 OK

# InvaderRadar改修1182 の差分（cr/1182-safe-apply 52db21c と main 0f865a6）の見立て

merge-base は 0f865a6（1181 が入った main を土台にしているので、1181 の差分の読みで書いた main.gd のぶつかりは起きない）。commit は 52db21c の 1 つ。依頼と CR は branch review/cr1182-r0p-2 の briefs/ir_cr1182_r0p2.md、R3' は review/cr1182-r3p-2 の results/cr1182_r3p_2.md と読み比べた。

## 1. 変わったファイル
- 変わったのは次のファイルだけ。
  - scenes/main.gd（1 行）
  - test/cr/test_cr_1182.gd（新しい）
  - test/cr/test_cr_1179.gd・test/cr/test_cr_1180.gd（書き直し）
  - test/cr/test_cr_1180.gd.uid（Godot が自動で作る印。決まりのとおり NG にしない）
- test_cr_1182.gd は、R3'（2 回目）の材料と 1 文字も違わない。
- test_cr_1179 の書き直しは −12／+12 行で、どれも vibrations の 120 を 250 に替える行だけ。R3'（2 回目）の材料と同じ。
  - `test_cr_1179_main_dead_swipe` は [120] → [250] の 1 行だけで、強さの表明は足されていない（1 回目の NG は直っている）。
- test_cr_1180 の書き直しは `test_cr_1180_main_vibrate_on_dead_transition` の 2 行（[15, 15, 15, 250]・[0.4, 0.4, 0.4, 0.3]）だけ。

## 2. main.gd
- _refresh の dead の分かれ道の sound.vibrate(120) を sound.vibrate(250, 0.3) に替えた 1 行だけ。依頼どおり。
- 変わっていないもの:
  - place（30）・mark（15, 0.4）・wrong（250, 0.3）の行。
  - dead を鳴らす決まり（curr_dead・last_dead と "mark" → "dead" の差し替え）。
  - 1178 のお知らせの待ち。
  - sound.gd・Sound.sfx_for。

## 3. 依頼に無い副作用
- 250・0.3 が出るのは sfx_name が "dead" か "wrong" の手だけで、分かれ道は 1 行の中身を替えただけ。
- dead にならない手では 250 は出ない。
  - × だけの組がすでにある盤で、組を増やす手は "mark" で 15。
  - × を消す手は ""。
  - チュートリアル・最初の _refresh は dead にしない。
- スワイプ: session.swipe は _commit・changed が 1 回なので、_refresh も 1 回。dead の 250 は 1 回だけ（CHECK 2、test_cr_1179_main_dead_swipe の [250]）。
- dead と wrong が同じ振動（250, 0.3）になったが、依頼の「NG のときは弱めで長め」のとおり。分かれ道は 2 つのまま残してあり、まとめる変更はしていない（依頼に無いので、それでよい）。
