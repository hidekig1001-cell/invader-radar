差分 OK

# InvaderRadar改修1187 の差分（cr/1187-safe-apply 69e4c97 と main 0ae3435）の見立て

merge-base は 0ae3435。commit は 69e4c97 の 1 つ。依頼と CR は branch review/cr1187-r0p の briefs/ir_cr1187_r0p.md、R3' は review/cr1187-r3p の results/cr1187_r3p.md と読み比べた。ユーザーの判断 D-20261027-1607＝A のとおりで読んだ。

## 1. 変わったファイル
- 変わったのは次のファイルだけ。
  - scenes/main.gd（+16 −4）
  - test/cr/test_cr_1187.gd（新しい）
  - test/cr/test_cr_1179.gd（−6／+6）
  - test/cr/test_cr_1182.gd（−2／+2）
  - test/cr/test_cr_1182.gd.uid（Godot の印。NG にしない）
- ほかのファイル・ほかの既存のテストは変わっていない。game/session.gd も変わっていないので、1186 とはぶつからない。
- test_cr_1187.gd は、R3' の材料と 1 文字も違わない（迷いの英語のコメントも同じに残っている）。
- test_cr_1179.gd の差分は、`test_cr_1179_main_dead_retrigger` の 3 段（count 1→2・2→3、vibrations の 3 つ）だけで、R3' で読んだ差のとおり。
- test_cr_1182.gd の差分は、`test_cr_1182_dead_vibration_not_retriggered` の 2 行だけで、R3' で読んだ差のとおり。

## 2. scenes/main.gd
- 依頼どおりの所:
  - var last_dead_marks: Array = [] を足した。
  - _refresh: curr_dead_marks はチュートリアルでなければ Rules.dead_marks(session.board, session.level)、チュートリアルなら []（初めの値のまま）。
  - curr_dead_marks のマスのうち 1 つでも last_dead_marks に無いものがあれば has_new_dead = true（見つけたら break）。
  - `(sfx_name == "mark" or sfx_name == "clear") and not last_snapshot.is_empty() and has_new_dead` で sfx_name = "dead"。
  - last_dead_marks = curr_dead_marks。
  - start_tutorial で last_dead_marks = []、end_tutorial で last_dead_marks = Rules.dead_marks(...)。
- 依頼と違う所（NG にはしない）: 依頼の箇条 1 は「var last_dead: bool = false を var last_dead_marks: Array = [] に替える」で、箇条 2・3 も last_dead を last_dead_marks に「替える」と書いている。差分は last_dead を消さずに残している。
  - 残している所: 宣言と、_refresh の `last_dead = not curr_dead_marks.is_empty()`、start_tutorial の `last_dead = false`、end_tutorial の `last_dead = not marks.is_empty()`。
  - 読む所は、branch の main.gd のどこにも無い（grep で書く 4 か所だけ）。音・振動の振る舞いは、依頼どおりに替えた場合と同じ。
  - 使われない変数を 3 か所で書き続けるのは、後で読む人が「last_dead で決めている」と読み違えるおそれがある。次に main.gd を触る CR で消すのがよい。
  - 依頼の文どおりに揃えたいなら、run に差し戻してこの 4 か所を消させる（判断は任せる）。
- 変えていないもの:
  - 振動の長さと強さ（place 30・mark 15/0.4・dead 250/0.3・wrong 250/0.3）。
  - line の決まり（last_lines・curr_lines・new_lines・flash_lines）。
  - 1178 のお知らせの待ち（size_up_wait など）。
- 細かい所: ループの変数名 `mark` と end_tutorial の局所の `marks` は、main.gd の中の名前とぶつからない（そういう名前の変数・関数は main.gd に無い）。

## 3. 下書きの try_bug_dead_new_group_patch.py との比べ
- 決まりは同じ。新しいマスがあるか、"mark"・"clear"、last_snapshot が空でない、チュートリアルなら []、入れ直し。
- 違い:
  - 下書きは last_dead を消して置き換える。branch は last_dead を残す（上の 2）。
  - 下書きは has_new_dead の判定を if の外に置き、branch は `if not is_tutorial():` の中に置いて break する。チュートリアルなら curr_dead_marks が [] なので、どちらも同じ結果。
  - `sfx_name in [...]` と `or` の書き方の違い。
- 依頼の決まりから外れる違いは無い。

## 4. 効果音の順
- dead への差し替えは "mark"・"clear" の手だけなので、level_clear・wrong・hint は替わらない。
- line への差し替え（"clear"・"place"・"mark" のとき）は dead の差し替えの後にある。dead にした手は line にならない。
  - 宇宙人 1 つと × の組と、× だけの組が同じ手でできると dead になる（test_cr_1184_dead_priority_over_line の筋で、変わっていない）。
- 順 level_clear > wrong > hint > dead > line > clear > place > mark は保たれている。

## 5. 写真の盤（レベル 6）の流れ
- 桃（区域 4）を × だけにする最後の × の手:
  - そのマスが前の dead_marks に無いので、新しいマスがあり、"mark" → "dead" で 250・0.3 の振動が出る。
- 続けて橙（区域 0。(0,4) は数字の岩で数えない）を × だけにする最後の × の手:
  - (0,1)〜(0,3) が新しく dead_marks に入るので、桃が × だけのままでも、もう一度 dead が鳴る。
- 順が逆でも同じ。2 つとも鳴る見立て。
- 古いセーブで (0,4) の岩に宇宙人がある盤から、その宇宙人を取って橙が × だけになる手:
  - 効果音は "clear" で、新しいマスがあるので dead になる。
  - 1186 が入った後は、岩の宇宙人をダブルタップで取る手も弾かれる。そのため、この形の盤は元に戻す手か、岩に触れない別の手でしか動かない。
