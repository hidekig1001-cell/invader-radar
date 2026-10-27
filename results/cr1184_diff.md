差分 OK

# InvaderRadar改修1184 の差分（cr/1184-safe-apply 40cd1d7 と main 5f52a46）の見立て

merge-base は 5f52a46。commit は 40cd1d7 の 1 つ。依頼と CR は branch review/cr1184-r0p の briefs/ir_cr1184_r0p.md、R3' は review/cr1184-r3p の results/cr1184_r3p.md と読み比べた。ユーザーの判断 D-20261027-0545＝A（答えとは比べない）のとおりで読んだ。

## 1. 変わったファイル
- 変わったのは次のファイルだけ。
  - scenes/sound.gd（+3）
  - scenes/main.gd（+18）
  - test/cr/test_cr_1184.gd（新しい）
  - test/cr/test_cr_1179.gd（−2／+2）
- core/rules.gd・game/・scenes/board_view.gd・ほかの既存のテストは変わっていない。.uid も無い。
- test_cr_1184.gd は、R3' の材料と 1 文字も違わない。
- test_cr_1179.gd は `test_cr_1179_main_dead_with_alien` の 64・69 行目の振動の並び 2 か所だけで、R3' で読んだとおり。
  - [30, 15, 15, 15] → [30, 15, 15]
  - [30, 15, 15, 15, 15, 250] → [30, 15, 15, 15, 250]

## 2. scenes/sound.gd
- 足したのは次の 2 つだけ。
  - const SFX_LINE := preload("res://assets/audio/line.wav")（place.wav と同じ assets/audio、ファイルは main にある）を SFX_DEAD の後に。
  - play_sfx の match の最後に "line": stream = SFX_LINE。
- Sound.sfx_for・vibrate・vibration_amplitudes・ほかの効果音は変わっていない。依頼どおり。

## 3. scenes/main.gd
- var last_dead の後に var last_lines: Array = [] を足した。
- _refresh: dead に替える所（`if not is_tutorial():` の中の curr_dead と "mark" → "dead"）の後に、次の 3 つがある。依頼どおり。
  - curr_lines: チュートリアルでなければ Rules.filled_lines(session.board, session.level)、チュートリアルなら []。else の `curr_lines = []` は言い直しで、害は無い。
  - new_lines: curr_lines のうち last_lines に無い組。辞書どうしの比べは中身で比べるので、同じ組は「前からある」と分かる。
  - sfx_name が "clear"・"place"・"mark" のどれかで、last_snapshot が空でなく、new_lines が空でないときだけ sfx_name = "line"。
- last_lines = curr_lines は last_dead = curr_dead のすぐ後。依頼どおり。
- 依頼の箇条に名前の無い 2 行がある。CR-1179 の last_dead と同じ扱いで、NG にはしない。
  - start_tutorial: last_dead = false の後に last_lines = []。
  - end_tutorial: last_dead の後に last_lines = Rules.filled_lines(session.board, session.level)。
  - どちらも last_snapshot・last_conflicts・last_dead を入れ直す所で、依頼の「last_dead = curr_dead のあとに last_lines = curr_lines」と同じ考え。
  - 振る舞いの面でも要る。チュートリアルの間は curr_lines が [] なので、end_tutorial で入れ直さないと、そろった組のある盤に戻った後の最初の手で、前からある組まで「新しい」と数えて line が鳴ってしまう。
- 変わっていないもの:
  - dead の決まり（curr_dead・last_dead）。
  - 振動の分かれ道（place 30・mark 15/0.4・dead 250/0.3・wrong 250/0.3）。
  - 1178 のお知らせの待ち。
- 振動: if/elif は sfx_name が "place" か "mark" のときだけ 30・15 を出す。line の手は sfx_name が "line" なので、× の 15 ms・宇宙人の 30 ms の振動は出ない（test_cr_1179 の書き直しの 15 が 1 つ減る筋）。line の手には振動が無く、依頼のとおり。
- 効果音の順: line への差し替えは clear・place・mark のときだけ。level_clear・wrong・hint・dead の手は替わらない（level_clear > wrong > hint > dead > line > clear > place > mark のとおり）。
- 最初の _refresh: last_snapshot が空なので line にしない。last_lines にはその時のそろった組が入る（CHECK 7 の筋）。
- 依頼に無い副作用:
  - 面の切り替え: 新しい盤は空で filled_lines は []。
  - ヒント: "hint" が先。
  - ANSWER（apply_hint）: 当てた手が組をそろえれば place・mark → line になるが、依頼の決めのとおり。
  - 困る所は見つからなかった。

## 4. 下書きの try_line_patch.py の sound() との比べ
- sound.gd: 同じ（SFX_LINE と "line" の 2 か所）。
- main.gd の _refresh: 結果は同じ。
  - 下書きは curr_lines の if に else が無く、差し替えの前にコメントがある。
  - branch は差し替えを dead の if のすぐ後に置き、下書きは `if sfx_name != "":` の直前に置く。どちらも dead の後・play_sfx の前で、同じ所。
- 違い: branch は start_tutorial・end_tutorial で last_lines を入れ直す（下書きには無い）。上に書いたとおり、依頼の決まり（新しくそろった組だけで鳴らす）を守るための足しで、決まりから外れていない。下書きより正しい。

## 5. InvaderRadar改修1185（光）が当たるか
- 当たる。
  - 下書きの flash() が main.gd に当てる所は `\t\tsound.play_sfx(sfx_name)\n` の 1 か所で、branch の main.gd にちょうど 1 回だけある（数えた）。
  - その後に `if sfx_name == "line": board_view.flash_lines(new_lines)` を足せる。
- new_lines は _refresh の関数の中の一番外の段（字下げ 1 つ）で、play_sfx の if より前に宣言されている。そのため play_sfx の所から名前で読める。名前も new_lines で、req_line_flash.txt と合う。
- 1185 の board_view.gd 側は、この差分で board_view.gd が変わっていないので、main の board_view.gd にそのまま当たる。
