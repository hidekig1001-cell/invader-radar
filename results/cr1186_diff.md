差分 OK

InvaderRadar改修1186（数字付きの岩に × も宇宙人も付けられないようにする）の差分の読み。branch cr/1186-safe-apply（70d15bf）と、その土台の main 0ae3435 を比べた。2026-10-27、クラウドセッション。

## 1. 変わったファイル — OK
- 差分は game/session.gd（+12・-3）と test/cr/test_cr_1186.gd（新しい、+51）の 2 つだけ。ほかのファイル・既存のテストは変わっていない。.uid の新しいファイルも無い。
- test_cr_1186.gd は、R3' の brief（review/cr1186-r3p の briefs/ir_cr1186_r3p.md）の「== tests/test_cr_1186.gd」の中身と一字一句同じだった（機械で比べた。1212 文字）。

## 2. game/session.gd — OK
- `func is_radar(x: int, y: int) -> bool` を is_asteroid の次に足している。level が null なら false。`for r in level.radar: if r[0] == x and r[1] == y: return true`、ほかは false。依頼どおり（level.radar は parse_radar が [x, y, n] の配列で入れる）。
- tap と double_tap の最初の判定が `if is_asteroid(x, y) or is_given(x, y) or is_radar(x, y): return false` になった。
  - `_commit` を通らないので、盤も手数（moves）も変わらない。依頼どおり。
- swipe の除くマスが `not is_asteroid(...) and not is_given(...) and not is_radar(...)` になった。
  - 除いたあとに `filtered_cells.is_empty()` なら false。これは今の行がそのまま働く。依頼どおり。
- is_asteroid・is_given・apply_hint・undo・solve_now・_commit・restore_dict など、ほかの関数は変わっていない。

## 3. 下書きの try_bug_radar_block_patch.py との違い
- 違いは 2 つで、どちらも働きは同じ。依頼の決まりから外れていない。
  - 判定の並び: 下書きは `is_asteroid or is_radar or is_given`、差分は `is_asteroid or is_given or is_radar`。or の並びが違うだけ。
  - is_radar の置き場所とコメント: 下書きは is_given の前に「数字付きの岩（レーダー）のマスかどうか」のコメントつきで置いた。差分は is_asteroid と is_given のあいだに、コメント無しで置いた。
- 当て試し: 差分（70d15bf）の写しで GUT を test/unit と test/cr で流した。741 件すべて通った。SCRIPT ERROR は 0 件。下書きを当てた写しの R0' のときの結果と同じ。

## 4. 1187 と合わせたとき — OK
- 1187（cr/1187-safe-apply、69e4c97）の差分:
  - scenes/main.gd（last_dead_marks で「新しい × だけの組」を数える形に替えた）
  - test_cr_1179・test_cr_1182 の書き直し
  - 新しい test_cr_1187
- 1186 が直すのは game/session.gd だけで、同じファイルに触らない。
- 1187 の写しに 1186 の差分を git apply で当て、GUT を流した（Godot 4.7.2、import をしてから）。744 件すべて通った。SCRIPT ERROR は 0 件。
- 振る舞いについて:
  - 1186 では、数字付きの岩のマスの tap・double_tap・swipe が _commit を通らず、`changed` も出ない。そのため main の _refresh も動かず、dead・line・振動の決まりには何も入らない。
  - × だけの組の数え方（Rules.dead_marks）は、もともと数字付きの岩のマスを数えない。1187 の last_dead_marks とも合う。

## 5. ヒント・答えがレーダーのマスに宇宙人を置く筋 — 見つからなかった（構えの上では残っている、注意）
- apply_hint は board.apply で直に置く。置くマスは Hint.next_hint の "next_piece" で、Solver.solutions(level, 1) の答えのマス。solve_now と、6×6 から上の面の最初の宇宙人（given）も、Solver の答えを使う。
- core/solver.gd の _backtrack は、小惑星（_is_asteroid）は除くが、**数字付きの岩のマスは除いていない**。数字の決まりは、最後に Rules.radar_satisfied（まわり 8 マスの数）で見るだけ。
- そのため、構えの上では、数字付きの岩のマスに宇宙人を置く答えが出る筋が残っている。そのマスの宇宙人は Rules.conflicts で赤くなり、is_solved にならない。
- 実際に起きるかを調べた。1186 の写しで、数字付きの岩のある 275 の面の答えを全部（limit 0）出し、どれかの宇宙人が数字付きの岩のマスにあるかを数えた。0 だった。
  - 内訳: level_pack の決まった面すべてと、GENERATED_SPECS の各段を種 3 つずつ LevelMaker.make_level で作った面。
  - LevelMaker は答えを先に決めてから、答えに無いマスに岩を置くので、今の作り方では起きない見込み。
- これは 1186 の範囲の外。気になるなら、Solver の _backtrack で `level.radar` のマスも小惑星と同じく飛ばす CR を別に出すと、構えの上でも筋が消える。答えの数は変わらない見込み（上の調べで 0 件のため）。

## そのほか
- 1186 の R0' で書いた注意（直す前に保存された進み具合で、岩の上にある宇宙人や × は、直したあとはタップでは取れない。ヒントか面のやり直しで取れる）は、差分の作りどおり残っている。
