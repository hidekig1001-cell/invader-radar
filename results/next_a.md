2 本: last_dead の片づけ 直しで全部通り、直しなしで probe 2 件だけ落ちる／dead_marks の順 直しで全部通り、直しなしで probe 3 件だけ落ちる

# InvaderRadar の次の改修 2 本（A 組）の調べと依頼の下書き（10/27、クラウドセッション。土台は main 9193cdf v1.96-cr1186）

置いたもの（branch draft/next-a の drafts/）:
- 1 本目: req_cleanup_last_dead.txt・req_cleanup_last_dead_probe.gd・try_cleanup_last_dead_patch.py
- 2 本目: req_dead_marks_order.txt・req_dead_marks_order_probe.gd・try_dead_marks_order_patch.py

1188（scenes/message_bubble.gd と main.gd の tick_size_up）とは、直す所が重ならない。どちらの台本も、1188 が入った main にもそのまま当たる見込み（当てどころの文字列が 1188 の直しと別の行）。

## 1 本目: 使われない last_dead を消す片づけ
- **今の作り**:
  - scenes/main.gd の `var last_dead: bool = false`（37 行）に、値を入れる所が 3 か所ある:
    - `_refresh` の `last_dead = not curr_dead_marks.is_empty()`（385 行）
    - `start_tutorial` の `last_dead = false`（433 行）
    - `end_tutorial` の `last_dead = not marks.is_empty()`（457 行）
  - 読む所はどこにも無い。テスト・.autedev/shot.gd・ほかの scenes にも、last_dead を読む所は無い（git grep で確かめた）。
  - 1187 で、dead の決まりが `last_dead_marks`（× だけの組のマスの並び）に替わったための残り。
  - test/cr/test_cr_1187.gd の `test_cr_1187_undo_dead_group` には、テストを作る役の迷いの英語のコメントがある。
    - 7 行（「# Wait, prompt says」から「# Let's trust the prompt's expected values.」まで）。
    - 2 つの表明の行の後ろにも、迷いのコメントが付いている。
- **依頼の要点**:
  - 変えること（3 行）: 宣言を消す。値を入れる 3 行を消す（end_tutorial の var marks と last_dead_marks = marks は残す）。ほかは変えない。
  - テストのコメントは「変わる既存のテスト」の test_cr_1187_undo_dead_group に、表明と手は変わらないこと、消すコメント、残すコメント（「# Fill region 0 with X」など 3 行）を書いた。
- **確かめる項目（2）**:
  1. `"last_dead" in m` は false、`"last_dead_marks" in m` は true。区域 0、続けて区域 3 を × で埋めると、dead が 2 回鳴り、振動は [15, 15, 15, 250, 15, 15, 15, 250]（1187 の「2 つ目の組でも鳴る」振る舞いが変わらない）。
  2. start_tutorial のあと・end_tutorial のあとも `"last_dead" in m` は false。チュートリアルを終えたあとの面で区域 0 を埋めると、dead が 1 回、振動は [15, 15, 15, 250]。
- **変わらない既存のテスト**: 36 個。
  - start_tutorial・end_tutorial・_refresh を呼ぶ main のテストを、test/ から全部拾った（1012・1018・1026・1037・1038・1043・1073・1077・1078・1083・1084・1086・1092・1134・1179・1180・1181・1184・pixel_1023_layout）。
  - test_cr_1187 の残り 2 つ。

## 2 本目: Rules.dead_marks の判定の順を filled_lines に合わせる
- **今の作り**:
  - core/rules.gd の dead_marks は、行・列・区域の 3 つのループで、マスごとに次の順で見ている:
    1. `state == 2`（宇宙人）なら has_alien = true で break
    2. 岩のマスなら continue
    3. ×／空
  - そのため、岩のマスの宇宙人を「宇宙人がいる組」と数える。
  - filled_lines は、岩のマスを先に飛ばすので数えない。
  - CR-1186 で岩のマスに新しく置けなくなったが、それより前に保存した盤では起きうる。
- **依頼の要点**:
  - 変えること（3 行）: 3 つのループで、岩のマスの continue を状態の判定より前に移す。状態の見方・返す並びは変えない。filled_lines・conflicts、ほかは変えない。
  - 決まりは箇条の中に書いた。
- **確かめる項目（3）**（Rules・BS・Level は関数の中の load。まだ無い関数は呼ばない）:
  1. レーダーの岩 (0, 0) に宇宙人、行 0 のほかが × → [(1, 0), (2, 0), (3, 0)]
  2. 小惑星 (3, 3) に宇宙人、行 3 のほかが × → [(0, 3), (1, 3), (2, 3)]。続けて岩でない (1, 3) に宇宙人 → []（ふつうの宇宙人は数える）
  3. 岩 (0, 0) に宇宙人で区域 0 → [(1, 0), (0, 1), (1, 1)]。列 0 も × にすると → [(1, 0), (0, 1), (1, 1), (0, 2), (0, 3)]（列でも同じ。並びは y → x）
- **変わる既存のテスト**: なし（当て試しで確かめた）。
- **変わらない既存のテスト**: 19 個。
  - dead_marks・mark_color_at を見るものと、dead の音を見るものを、test/ から全部拾った（1130・1137・1173・1174・1179・1184・1187・pixel_1023）。
  - 岩のマスに宇宙人を置くテスト（pixel_1023・1130・1137）は、宇宙人を置いた盤では radar_text_color だけを見て、mark_color_at を見る盤は岩に × だけ、と理由を分けて書いた。

## 当て試しの結果（Godot 4.7.2、main 9193cdf の写し、GUT を test/unit と test/cr で流した。2 本の probe を両方置いた）

| 写し | 当てたもの | 結果 |
|---|---|---|
| 1 | 直しなし | 749 件のうち、落ちたのは 5 件で、probe の 5 件ちょうど（片づけ 2・順 3）。SCRIPT ERROR は 0（ファイルは読み込めている） |
| 2 | try_cleanup_last_dead_patch.py だけ | 落ちたのは順の probe 3 件だけ。片づけの probe 2 件と既存のテストはすべて通った（test_cr_1187 のコメントを消しても通る） |
| 3 | try_dead_marks_order_patch.py だけ | 落ちたのは片づけの probe 2 件だけ。順の probe 3 件と既存のテストはすべて通った |
| 4 | 2 本とも | 749 件すべて通った |

## 迷った点
1. **片づけの項目の書き方**: 依頼の例どおり `"last_dead" in m` が false になることを確かめる。そこに、1187 の振る舞いが変わらないこと（2 つ目の組でも鳴る、チュートリアルのあとも鳴る）を、同じ項目の後ろに入れた。振る舞いだけの項目は今のコードでも成り立つので、C19 に当たらないよう、どの項目も頭に `"last_dead" in m` を置いた。
2. **テストのコメントを消すのは「変わる既存のテスト」**: 表明は変わらないが、ファイルが変わるので、依頼の指示どおり「変わる」に書いた。「A は B に変わる」は、表明の行の後ろのコメントを消す 2 か所に使い、7 行のコメントは「消える」と書いた。
3. **decision**: 決まりの番号が手元に無いので「未定（Invader Radar30 が入れる）」とした。
