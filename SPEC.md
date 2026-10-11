# SPEC: インベーダー・レーダー（縦画面のロジックパズル）

ゲーム A（仮名「インベーダー・レーダー」）。設計は D:\AI\puzzle_base_design_20261011.md、手本の覚え書きは D:\AI\game_a_notes_20261011.md。

## 0. ゲームの決まり（v0.4-cr1003 の時点）
- 盤は N×N（1〜5 面は 4×4、6〜10 面は 5×5）で、色の違う N 個の区域に分かれている。
- 遊び手は駒（あとでインベーダーの絵にする）を N 個置く。
- 決まり: 各行に 1 つ、各列に 1 つ、各区域（色）に 1 つ。駒どうしは縦・横・斜めのどれでも隣り合ってはいけない。
- 決まりをすべて満たして N 個置くと、その面はクリア（`core/rules.gd` の `is_solved`）。決まりに反している駒は `Rules.conflicts` で分かる（まだ画面には出していない）。
- どの面も答えはちょうど 1 つ（`core/solver.gd` で確かめている）。
- 遊び手は、駒が入らないと分かったマスに × を付けて考える（× は答えに関係しない、メモ）。
- 画面の文字は英語だけ（既定のフォントに日本語がない）。今ある画面: 上に HUD（LEVEL・SCORE・HINT の残り、UNDO・SETTINGS のボタン）、その下に吹き出し（最初の 4 秒だけ操作の説明 "TAP: X   DOUBLE TAP: PIECE   SWIPE: X"）、真ん中に盤、下に HINT のボタン（今は残りの数を減らすだけ）。
- まだないもの: ルールの説明の表示、ぶつかっている駒の表示、ヒントの中身、小惑星、レーダーの数字、インベーダーの絵、効果音。

## 1. 層の分け方（mobile-invaders と同じ並び）
- `core/` 規則の層。Node に触れない。乱数は注入（土台にはまだ乱数はない）。
- `game/` 面の層。面の情報・操作の読み替え・手数やスコア。Node に触れない（signal は使う）。
- `scenes/` 画面の層。配置・入力・描画・表示。状態を変える判断をしない（session に任せる）。
- `data/levels/` 面の JSON。 `test/unit/` GUT のテスト。 `tools/run_tests.sh` 試験の入口。 `.autedev/` 改修 run 用（`shot.gd` 撮影の台本、`notes/` 役への補足）。

## 2. ファイルの役目
- `core/grid.gd`: 盤（int のマス）。`get_cell`・`set_cell`・`in_bounds`・`neighbors4`・`neighbors8`・`copy`・`to_rows`・`load_rows`。盤の外の `get_cell` は既定 -1。
- `core/board_state.gd`: 遊び手の印。マスは `EMPTY`・`MARK`（×）・`PIECE`（駒）。`apply(action, x, y) -> int`（action は "mark"・"place"・"clear"。盤の外・知らない action は `ERR_INVALID_PARAMETER`、すでにその状態なら `OK` で何も変えない）、`undo()`、`pieces()`、`marks()`、`snapshot()`（"width"・"height"・"rows"（"." "x" "P" の文字列の並び）・"marks"・"pieces"）。
- `core/rules.gd`（CR-1001）: `conflicts(board_state, level) -> Array`（決まりに反している駒のマス、y の小さい順・同じ y なら x の小さい順）、`is_solved(board_state, level) -> bool`（駒が `level.target` 個で、`conflicts` が空）。
- `core/solver.gd`（CR-1002）: `solutions(level, limit := 0) -> Array`（答えの並び。1 つの答えは行ごとの Vector2i の並び）、`count_solutions(level, limit := 0) -> int`。
- `game/level_pack.gd`（CR-1003）: `level_dicts() -> Array`（10 面の辞書）。`session.load_default_levels()` はここから読む。`data/levels/*.json` と `LEVEL_PATHS` は使っていない。
- `game/level.gd`: 1 面。`id`・`width`・`height`・`regions`（区域の番号の Grid）・`asteroids`・`radar`（Vector2i の並び。土台では空）・`target`。`parse(dict)`・`parse_json(text)`・`load_file(path)`・`to_dict()`・`to_json()`。形が違えば false で中身は変えない。
- `game/session.gd`: 面の並び・今の面・`moves`・`score`・`hints`（既定 3）・`status`（"playing" か "cleared"）。`tap`・`double_tap`・`swipe`・`undo`・`use_hint`・`next_level`・`restart_level`・`snapshot()`（"level"・"moves"・"score"・"hints"・"status"・"board"）。状態が変わると `changed` を出す。
- `scenes/main.gd`・`main.tscn`: 縦 1080x1920。`session` を持つ（撮影が読む）。タッチを集めて `input_mapper` で読み、session に渡す。
- `scenes/input_mapper.gd`: Node に触れない関数。`cell_at`・`classify`（1 本のなぞり → tap・double_tap・swipe・none）・`map_all`・`cells_along`。
- `scenes/board_view.gd`（盤・色・× ・駒）、`hud.gd`（面・スコア・ヒントの残り・ボタン）、`message_bubble.gd`（吹き出し）。文字は英語（既定のフォントに日本語が無い）。

## 3. 操作の決まり（覚え書きより）
- 1 回タップ: 空→×、× をもう一度タップ→消す。駒の上のタップは何もしない。
- ダブルタップ（300ms 以内に同じマス）: 空・×→駒を置く。駒の上→取り除く。
- スワイプ: なぞった空のマスに ×（× や駒はそのまま）。全体で 1 手。
- 手数: 状態が変わった操作 1 回につき 1 手。`undo` は手数を変えない。
- スコア: 面を解くと +100（`CLEAR_SCORE`）。クリア後は次の面へ進むまで操作を受けない。`next_level` は最後の面の次で最初の面に戻る。スコアとヒントの残りは引き継ぐ。

## 4. 面の JSON
`{"id", "width", "height", "regions": [[行ごとの区域の番号]...], "asteroids": [[x, y]...], "radar": [[x, y]...], "target"}`。今の 10 面は `game/level_pack.gd` にこの形の辞書で入っている（"asteroids"・"radar" は省いている）。

## 5. CR を書くときの注意
- 1 つの CR は 1 つの層に収める。規則（core）と表示（scenes）を同じ CR で変えない。
- 1 ファイルは 15KB まで。大きくなるなら分ける。
- 決まりを足す順は設計書 5 章（決まり → 解く関数 → 面を作る関数 → 小惑星 → レーダー → ヒント → 面の並び → チュートリアル → 見た目）。
- 面の JSON の答えをテストに直接書かない。答えの数は「解く関数」で数える。
- GDScript は Godot 4 の書き方だけ。`:=` は型が決まる式にだけ使い、JSON など型が決まらないものは `var x = ...`。`JSON.parse_string` は壊れた文字でエンジンのエラーを出す（GUT が失敗にする）ので、`JSON.new().parse()` を使う。
- `.autedev/shot.gd` が読む `main.session` と、`session.snapshot()["board"]` の "marks"・"pieces" は残す。
- **チュートリアルを合わせて直す（10/11 ユーザー「crが進んだらチュートリアルも直さないといけない」）**: 決まり・操作・画面の言葉を変える CR は、チュートリアルの段のデータ（`game/tutorial_steps.gd`、CR-1011 から）の文と手順も同じ CR で直す（対象の候補と「変わる既存のテスト」に入れる）。チュートリアルの仕組み（`game/tutorial.gd`）は、段のデータを読むだけにして、決まりを書き込まない。
