差分 OK

# InvaderRadar改修1191 の差分（cr/1191-safe-apply 372d724 と main 8111de3）の見立て

merge-base は 8111de3。commit は 372d724 の 1 つ。依頼と CR は branch review/cr1191-r0p-2 の briefs/ir_cr1191_r0p-2.md、R3' は流し直しの run の review/cr1191-r3p-2（results/cr1191_r3p_2.md、OK）と読み比べた。

## 1. 変わったファイル
- 変わったのは scenes/main.gd（−4）と test/cr/test_cr_1191.gd（新しい、+65）だけ。
- test/cr/test_cr_1187.gd を含め、ほかのファイル・既存のテストは変わっていない。.uid も無い。
- test_cr_1191.gd は、流し直しの run の R3'（2 回目）の材料（review/cr1191-r3p-2 の briefs/ir_cr1191_r3p-2.md）と 1 文字も違わない。
- brief は R3' を review/cr1191-r3p の結果と書いているが、取り込まれたのは流し直しの run のテストで、2 回目の材料と同じ。

## 2. scenes/main.gd — 依頼どおり
- 消したのは次の 4 行だけで、足した行は無い。
  - 宣言 `var last_dead: bool = false`（36 行目のあたり）
  - _refresh の `last_dead = not curr_dead_marks.is_empty()`
  - start_tutorial の `last_dead = false`
  - end_tutorial の `last_dead = not marks.is_empty()`
- 変わっていないもの:
  - end_tutorial の `var marks = Rules.dead_marks(session.board, session.level)` と `last_dead_marks = marks`（差分の前後の行に残っている）。
  - 1189 で足した _refresh の `if last_snapshot.is_empty(): sfx_name = ""`（branch の 343 行目）。
  - last_dead_marks・last_lines・dead に替える決まり（354 行目）・line に替える決まり（368 行目）・振動。

## 3. last_dead を読む所が残っていないか
- branch 全体を `\blast_dead\b` で git grep した（briefs・results・drafts を除く）。
  - 当たるのは test/cr/test_cr_1191.gd の `"last_dead" in m` の 3 か所だけ。どれも文字で有る無しを調べるだけで、名前で読まないので Parse Error にならない。
  - main.gd・ほかの scenes・game・core・ほかのテストに、last_dead を読む所・書く所は無い。
- .autedev/ は branch に入っている（allow.json・notes/ など）が、.autedev/shot.gd は無い。上の git grep は .autedev/ も含めて調べていて、last_dead を読む所は無い。

## 4. 下書きの try_cleanup_last_dead_patch.py（draft/next-a）との比べ
- main.gd の部分は、下書きの 4 つの置き換え（宣言と 3 行を "" にする）と、行も中身も同じ。
- 下書きの test_cr_1187.gd のコメントの片づけは、今回の依頼から外したので、branch に無くてよい（無い）。
