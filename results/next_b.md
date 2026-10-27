3 本: Solver 直さない（一意の面ではレーダーの答えが出ず、_backtrack を直すと面の作り方が変わる）／最初の音 直す（立ち上げの _refresh で place・mark・wrong と振動が出ている）／区域の番号 直す（Level.parse で 0 から詰め直す。今の面では何も変わらない）

# InvaderRadar の次の改修 3 本（B 組）の調べ（main 9193cdf、2026-10-27、クラウドセッション）

このクラウドには Godot が無く、Godot のダウンロード元（github.com・tuxfamily）もこの環境のネットワークの決まりで止められている。probe は流していない（下の「当て試し」）。調べはコードを読んで、計算は手と Python で行った。

## 1. Solver がレーダーのマスに宇宙人を置く答え — 直さない（推す）
- 今の作り: core/solver.gd の _backtrack は、小惑星（_is_asteroid）を除くが、レーダーのマスを除かない。答えの終わりに radar_satisfied を見るだけ（レーダーの数は自分のマスを数えない）。
- 今の面で起きない理由（一意の面では起きえない）:
  - 面を作る所（LevelMaker.make_level・make_level_greedy）は、答え（solution）から次のように作る。
    - レーダーの数字を、答えでないマスにだけ置く（pick_radar の empty_cells、greedy の cells）。
    - 小惑星も答えでないマスにだけ置く。
  - そのあと has_unique_solution（Solver.count_solutions(level, 2) == 1）が真の面だけを使う。
  - 作った答えは Solver の決まり（行・列・区域が 1 つずつ、上下の行で隣り合わない、小惑星でない、レーダーの数が合う）をすべて満たすので、Solver はその答えを必ず見つける。
  - 数えて 1 つなら、その 1 つが作った答えで、レーダーのマスに宇宙人は無い。
  - 固定の 1〜10 面も、Solver を Python に写して数え、どれも答えは 1 通りで、レーダーのマスを使わなかった（前の調べ results/bug_dead_radar.md の 2）。
  - したがって、ヒント（Deduce・Hint）・答え（solve_now・apply_hint）・6×6 からの最初の宇宙人（Session._start_level の given）・先読み（level_prefetch）が使う Solver.solutions(level, 1) は、今のどの面でもレーダーのマスを返さない。brief の「275 面で 0」とも合う。
- 直すと困ること:
  - _backtrack でレーダーのマスを除くと、Solver.count_solutions の数も変わる。
  - make_level・make_level_greedy は「1 つになるまで」試しやレーダーを足すので、ある種（seed）で今は弾かれている試しが通るようになり、作られる面そのもの（レーダーの数・場所）が変わりうる。
  - 作った面の中身を決め打ちで確かめている既存のテスト（test_cr_1125・test_cr_1149・test_cr_1154・test_cr_1052・test_cr_1063 など）が赤くなるおそれがあり、Godot 無しでは前もって確かめられない。
  - 得るものは「一意でない面」（make_level が MAX_ATTEMPTS を使い切ったときの予備の面）だけ。その面では、レーダーと関係なく答えが 2 通り以上あり、ヒントがずれる。
- どうしても芽を摘みたいとき（推さない）:
  - 面を作る所の数え方は変えずに、答えを使う所だけでレーダーのマスを除く形にする。
  - 例: Solver に `static func answers(level, limit)` を足し、solutions の結果からレーダーのマスを含む答えを捨てて返す。Session・Deduce・level_prefetch の 4 か所をそれに替える。
  - 今の面では結果が変わらないので、既存のテストは変わらない見込み。
  - 1186 の後は、レーダーのマスへの tap・double_tap は弾かれるが、apply_hint（board.apply を直に呼ぶ）は弾かれない。この形なら、その抜け道も一緒に塞げる。
  - 下書きはしていない。要るなら言ってほしい。

## 2. 立ち上げの最初の _refresh で音と振動 — 直す（下書きあり）
- 今の作り（main 9193cdf）:
  - main の _ready の最後の `_refresh()` で、last_snapshot が {} のまま Sound.sfx_for(last_snapshot, curr_snapshot, 0, curr_conflicts) を呼ぶ。
  - 進み具合の読み直し（session.restore_dict）は _ready の中で changed を繋ぐ前にするので、最初の _refresh はこの 1 回。
  - sfx_for は {} を「何も無い盤」と読むので、盤の中身で鳴る。
    - ぶつかった宇宙人がある → conflicts > 0 で "wrong"、250 ms・0.3。
    - 宇宙人がある → "place"、30 ms。
    - × だけ → "mark"、15 ms・0.4。
    - 空の盤なら ""。
  - level_clear にはならない（前の status が "" なので）。
  - dead・line への差し替えは、今も last_snapshot が空なら起きない（1184・1187 の条件）。元の効果音と振動だけが出ている。
  - 既存のテスト test_cr_1179_main_dead_initial_state が、立ち上げで [15] が出ることを今の値として確かめている。これで、この作りで鳴っていることがはっきりしている。
- 直し方: _refresh で sfx_for の直後に `if last_snapshot.is_empty(): sfx_name = ""`。2 回目からは今のまま。
  - 下書き: drafts/req_quiet_first_refresh.txt
  - probe: drafts/req_quiet_first_refresh_probe.gd（3 関数）
  - try の直し: drafts/try_quiet_first_refresh_patch.py
  - 変わる既存のテストは 1 つ: test_cr_1179_main_dead_initial_state の 2 か所。[15] → []、[15, 250] → [250]。
  - 「変わらない既存のテスト」には、main を立ち上げて played・vibrations・flashes を見ているテストを全部挙げた（41 個。test_cr_1033・1038・1140・1177・1179・1180・1181・1182・1184・1185・1187）。
- 関わる別の筋（今回は直さない）:
  - app.gd の on_cloud_pulled は、遊んでいる途中に session.restore_dict を呼ぶ。そのときの _refresh は last_snapshot が前の盤なので、盤の違いで効果音・振動（line・dead も）が出うる。
  - 要るなら別の CR で、restore_dict の後の _refresh を静かにする（例: restore の前に last_snapshot = {} にする）。

## 3. 区域の番号が飛んでいる面 — 直す（下書きあり）
- 今の作り:
  - Level.parse は番号をそのまま Grid に入れる。region_count() は「出てきた番号の数」。
  - range(level.region_count()) で区域を回しているのは 4 か所。
    - core/rules.gd の dead_marks・filled_lines。
    - core/deduce.gd の 2 か所（ヒントの考え）。
  - 番号が 0・2・5・7 なら 0〜3 を回すので、1・3 は空回りし、5・7 を見ない。
  - Solver は region_count() == width を見るだけで、区域は番号そのままで比べるので困らない。
  - 今のデータは困らない。固定の面・作る面（grow_regions は 0 から）・test/ の中の面の辞書を Python で全部調べ、番号はどれも 0 から続いていた。
- 直し方（推す）: 4 か所を直すのではなく、面を読む所（Level.parse）で番号を小さい順に 0, 1, 2, … に詰め直す。
  - 番号の大小の並びは保つので、0 から続いている今の面ではまったく同じ値になり、既存のテストは変わらない（変わる既存のテスト: なし）。
  - rules.gd・deduce.gd には触らない。
  - 下書き: drafts/req_region_gaps.txt
  - probe: drafts/req_region_gaps_probe.gd（3 関数。番号の詰め直し・dead_marks・filled_lines。期待値は値まるごとで「[] にしない」を書いた）
  - try の直し: drafts/try_region_gaps_patch.py
  - to_dict は詰め直したあとの番号を書く（番号が飛んだ面を保存すると、詰めた番号で保存される）。

## A 組（draft/next-a）と重なる所
- 1（直さない）: 重ならない。
- 2: A 組と同じ scenes/main.gd の _refresh に触る。
  - 2 が足すのは `var sfx_name = Sound.sfx_for(…)` の直後の 3 行。
  - A 組の last_dead の片づけは、同じ関数の後ろの方（`last_dead = not curr_dead_marks.is_empty()` の行）と start_tutorial・end_tutorial。
  - 行は離れているので git の当たりはぶつからない見込み。どちらが先でも、後の方の try の直しは置き換える文が 1 回だけあることを確かめてから当てる。
- 3: A 組の Rules.dead_marks の判定の順の直しとは、ファイルが違う（3 は game/level.gd だけ）。ぶつからない。dead_marks の中身にも触らない。

## 当て試し
- 2 と 3 の try の直しを main 9193cdf の写し（git archive）に当てた。置き換える文がどちらもちょうど 1 回あり、当たることを確かめた。
- probe と既存のテストは流していない（Godot が無い）。
- 期待値は main のコード（Sound.sfx_for・main.gd の _refresh・Rules.dead_marks の並べ替え・filled_lines の並び・Level.parse）を手で追って決めた。
- 直しなしで落ちる所:
  - 2: 項目 1 は played が ["place"]。項目 2 は ["wrong"]。項目 3 は ["mark"]。
  - 3: 項目 1 は region_at(2, 0) が 2。項目 2 と 3 は 7 の区域を見ずに []。
- ローカルで当て試しをするときは、写しの根で try の直しを流してから tools/run_tests.sh で probe と既存のテストを流してほしい。1188 が入った main でも、2 の置き換える文（sfx_for の行）は変わらないので当たる。
