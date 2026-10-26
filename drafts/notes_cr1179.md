# CR-1179 の調べ（10/26、main = v1.83-cr1174 / 8b632f5）

ユーザーの Pixel の確かめ 10/26 06:28「5 okだけと音（テンション下がる効果音）のスマホの振動を入れて」。
行・列・色（区域）のどれかが × だけで埋まった瞬間に、効果音 `dead` を鳴らして 120 ミリ秒振動する。

## 直す関数

| ファイル | 関数・宣言 | 直すこと |
|---|---|---|
| scenes/sound.gd | 頭の const | `const SFX_DEAD := preload(".../audio/dead.wav")` を `SFX_BUTTON` の次に足す |
| scenes/sound.gd | `play_sfx` | match に `"dead": stream = SFX_DEAD` を足す（`played` に "dead" が入る） |
| scenes/main.gd | 頭の var | `var last_dead: bool = false` を `last_conflicts` の次に足す |
| scenes/main.gd | `_refresh` | `Sound.sfx_for` のあとに `curr_dead` を出し、条件が合えば `sfx_name` を "dead" にする。`play_sfx` のあと "dead" なら `sound.vibrate(120)`。最後に `last_dead = curr_dead` |

- `Sound.sfx_for`（static、4 つの引数）は変えない。引数を足すと test_cr_1033 の 6 つの呼び方に影響が出るのと、`sfx_for` は盤の数（marks・pieces）しか持っておらず `Rules.dead_marks` を出すには盤と面が要るため、差し替えは main.gd の `_refresh` でする。
- `core/rules.gd` の `Rules.dead_marks` は読むだけ（author の決まり「規則と表示を 1 つの CR で両方変えない」）。
- 振動の `vibrate` と `vibrations` は CR-1177（まだ main に無い）で入る。try_1179_patch.py は sound.gd に `func vibrate(ms: int) -> void:` が無ければ先に CR-1177 の直しを当てる。

## 鳴らす決まり（依頼に書いた形）

- 「瞬間」は、`_refresh` の前回と今回で `Rules.dead_marks(session.board, session.level)` が **空 → 空でない** に変わったとき。
- 効果音の順は **level_clear > wrong > hint > clear > place > dead > mark**。実装は「`sfx_for` が "mark" を返したときだけ dead に替える」。
  - × だけの組ができる手は、必ず × が増える手（タップで × を付ける・スワイプ・× を消す手の UNDO）。宇宙人を置く・取る手では組はできない（取ったマスは空になるので「× だけ」にならない）。だから "mark" の手だけを見れば足りるし、level_clear・wrong・hint・clear・place とぶつからない。
- 除くもの:
  - チュートリアルの間（`is_tutorial()` のとき curr_dead は false）。CR-1174 の吹き出しもチュートリアルでは出さないのと揃えた。チュートリアルの面には 1 マスだけの区域（(3, 1) と (0, 2)）があり、入れると test_cr_1038 の mark の音が dead に替わる恐れもある。
  - main を立ち上げた最初の `_refresh`（`last_snapshot` が空）。保存した進み具合を読み直した盤に × だけの組があると、起動しただけで dead と振動が出てしまうため。今のコードでも最初の `_refresh` は "mark" か "place" を鳴らしている（前からの癖。この CR では触らない）。
- 次の面・やり直しでは盤が空になるので、`_refresh` で last_dead は false に戻る（項目 6 で確かめる）。

## 確かめる項目（probe: req_cr1179_probe.gd の CHECK 1〜8）

1. `s.play_sfx("dead")` で `s.played` が ["dead"]。
2. 区域 0 を × 4 つで埋めた瞬間に "dead"・振動 [120]。3 つ目までは dead 0 回・振動 []。
3. 宇宙人がいる行 0 を × で埋めても鳴らない（振動は置いたときの [30] だけ）。続けて区域 1 を埋めると "dead"・[30, 120]。
4. 組がすでにあるときに行 0 も埋まって組が増えても鳴らない。× を 2 つ消して空に戻し、行 0 を埋め直すと再び "dead"・[120, 120]。
5. 1 回のスワイプで行 3 を埋めても "dead"・[120]。
6. 面を 3 つ作り、1 面目で鳴らしてから next_level、2 面目で再び埋めると再び鳴る（[120, 120]）。
7. × だけの組がある盤から立ち上げても最初は鳴らない。× を消して付け直すと鳴る。
8. チュートリアルの盤で 1 マスの区域を × で埋めても鳴らない。チュートリアルを終えたあとの面では鳴る。

決まり（C19）のため、期待値に今のコードにある "mark" は使わず、「鳴らない」は `played` の中の "dead" の数と `vibrations` で書いた。どの項目も最後に dead が鳴る場合を入れてあり、CR-1177 だけを当てた写しでは 8 項目とも落ちる（下の結果）。

## 影響を受けそうな既存のテスト（test/ を sfx_for・play_sfx・played・_refresh・dead_marks で grep）

- 変わるもの: なし。
- 変わらないもの（依頼に `ファイル::関数 — 理由` で挙げた 22 個）:
  - test_cr_1033.gd の sfx_for 6 つ — `sfx_for` を変えない。
  - test_cr_1033.gd::test_main_played_mark_on_tap — 最初の面の (0, 0) の区域は 7 マスなので 1 つの × では組ができない。
  - test_cr_1038.gd の 4 つ — チュートリアルでは dead にしない。
  - test_cr_1174.gd::test_cr_1174_dead_marks_warning — 区域 0 を埋めるので dead が鳴るが、見ているのは吹き出しの文だけ。
  - test_cr_1173.gd の 2 つ、test_cr_1151、_refresh を呼ぶ 1026・1073・1078・1084・1134。
  - grep に出た test_cr_1107・1113・1115 は名前に refresh が入っているだけ（雲の保存のトークンの refresh）で関係ない。

## 当て試しの結果（このセッションで Godot 4.7.2 を落として流した）

- main（8b632f5）の写しに try_1179_patch.py を当てた（dead.wav は無音の 0.5 秒を作って置いた。CR-1177 の直しも先に当たった）。
- `--import` のあと GUT を test/unit と test/cr で流した: **703 件すべて通った**（既存の 695 件 + probe の 8 件）。
- tools/run_tests.sh（1 読み込み・2 600 フレームの煙テスト・3 test/unit）: 失敗 0。
- 比べのため、CR-1177 の直しだけを当てた写しで probe を流した: **8 件とも落ちた**（今のコードでは成り立たない期待値になっている）。直しを何も当てない main では `vibrations` が無いので 8 件とも落ちる。

## 迷った点

1. **組が増えたときも鳴らすか**: 依頼では鳴らさない（空 → 空でない だけ）にした。吹き出しも組の数にかかわらず同じ文なので、それに揃えた。続けてまちがえたときにも気づかせたいなら、次の CR で `last_dead` を組の数（`Rules.dead_marks` のマスの数ではなく、× だけの行・列・区域の数）にして「増えたら鳴らす」に変えられる。ただし `dead_marks` はマスの並びしか返さないので、組の数を出すには規則の層に関数を足す CR が別に要る。手軽な代わりは「`dead_marks` のマスの数が増えたら鳴らす」だが、組が増えても新しいマスが増えない場合（例: 区域 0 が組のとき、(0, 0) と (1, 0) だけの 2 マスの行が組になる面）は鳴らないので、組の数とは一致しない。
2. **UNDO で組が戻るとき**: × を消した手を UNDO すると × が増えて組が戻り、"mark" の手なので dead が鳴る。「× だけの組ができた瞬間」には当たるので、そのままにした（項目には入れていない）。
3. **起動の最初の `_refresh`**: `last_snapshot` が空のときは鳴らさない形にした。代わりに `_ready` で last_dead を先に入れる形もあるが、変えることの箇条が増えるので選ばなかった。
4. **decls の書き方**: `const SFX_DEAD := preload("res://...dead.wav")` と全部書くと、C25（assets の道）に当たるかもしれないので `"const SFX_DEAD"` だけにした。検査が宣言の全体の一致を見る場合は書き直しが要る。
5. **dead.wav**: files.new には入れていない（改修 run では wav を作れない。別に用意して先に入れておく）。入れる前に改修 run を流すと preload で読み込みが止まる。
6. **origin.step の「CR 3 つ目」**: CR-1176（許可）・CR-1177（置いたとき）に続く 3 つ目と読んだ。CR-1178 がこの段の中にあるなら番号を直す。
7. **振動の長さ**: 依頼どおり 120 ミリ秒。置いたときの 30 ミリ秒より長く、Pixel で違いが分かるかは人の確かめ（human）に入れた。
