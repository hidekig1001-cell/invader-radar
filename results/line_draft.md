# 手触りの 2 本目「そろったら line の音と光」の依頼の下書き（10/27、クラウドセッション）

- branch: draft/line（土台は main 05834fd。1179〜1182 が入った後の main を前提に書いた）
- commit: このファイルを入れた commit（git log -1 で見る）
- drafts/ に置いたもの:
  - 依頼: req_line_rules.txt・req_line_sound.txt・req_line_flash.txt（3 本。YAML は ```yaml の囲み）
  - probe: req_line_rules_probe.gd・req_line_sound_probe.gd・req_line_flash_probe.gd
  - try_line_patch.py（`python3 try_line_patch.py [rules|sound|flash]`。前提の 1179〜1182 が無ければ先に当てる）
  - try_1179〜1182_patch.py（前提の直し。draft/cr1180 の写し）
  - notes_line.md

## 分け方と順番
1. **rules**: core/rules.gd に `Rules.filled_lines(board_state, level)` を足す（変えること 2 行）。
2. **sound**: 新しくそろった組がある手で line を鳴らす（変えること 4 行）。
   - sound.gd に SFX_LINE と play_sfx の "line" を足す。
   - main.gd に last_lines を足し、_refresh の dead のあとで line に替える。
3. **flash**: そろった組のマスを 0.3 秒、白で光らせる（変えること 5 行）。
   - board_view に flashes・flash_cells・flash_start・flash_lines・flash_alpha を足し、_draw・_process を直す。
   - main.gd で line の手に flash_lines を呼ぶ。

依頼は「音」と「光」の 2 本の案だったが、3 本にした。author の決まり「規則（core/）と表示（scenes/）は 1 つの CR で両方変えない」があるため、判定を規則の CR に分けた。line.wav は main にあるが、sound.gd からは使われていない。

## 決まり（提案）
- **そろった組**: 行・列・区域のうち、小惑星とレーダーを除くマスが全部「宇宙人か ×」で、宇宙人がちょうど 1 つ、その宇宙人が赤くない組。答えとは比べない（ヒントを使わずに正解が分かってしまうため）。
- **効果音の順**: level_clear > wrong > hint > dead > line > clear > place > mark。
  - 新しくそろった組がある手で、clear・place・mark を line に替える。
  - 増えたときも鳴らす。くずれてから再びそろえば再び鳴らす。
  - チュートリアルの間と、最初の _refresh では鳴らさない。
- **光**: line を鳴らした手だけ光らせる。dead・level_clear の手は光らせない。

## 確かめる項目の要約
- **rules（5）**
  1. 空が残ると []、埋めきると [行 0]
  2. 宇宙人 2 つの行と × だけの行はそろわず、宇宙人 1 つにすると [行 0]
  3. 赤い宇宙人の行はそろわず、赤くなくなると [行 0]
  4. 並びは行 → 列 → 区域
  5. 小惑星とレーダーのマスを除く
- **sound（10）**
  1. play_sfx("line")
  2. 宇宙人を置いてそろう
  3. × を付けてそろう、2 つ目の組でも鳴る
  4. × を消して戻すと再び鳴る
  5. 赤い宇宙人を取ってそろう（clear の手）
  6. 宇宙人 2 つでは鳴らない
  7. 最初の _refresh では鳴らない
  8. 面のクリアの手は level_clear（line の数は増えない）
  9. チュートリアルでは鳴らない
  10. dead と同じ手では dead
- **flash（4）**
  1. flash_lines の記録と明るさ（0.5 → 0.25 → 0）
  2. line の手だけ光る
  3. 2 つの組が同時にそろうと両方光る（同じマスは 1 回）
  4. dead の手は光らない

## 当て試し（Godot 4.7.2、738 件）
「1179〜1182 が入った後の main」の写し（F）を作った。main 05834fd に 1179〜1182 の直しと probe を当て、それぞれの「変わる既存のテスト」を書き換えたもので、719 件すべて通った。その上で次のとおり流した。
- 何も当てない F: line の probe 19 件がすべて落ちた。
- rules だけ: rules の 5 件が通った。
- rules ＋ sound: sound の 10 件も通った。
- 3 本とも: line の probe 19 件がすべて通った。既存で落ちたのは、音の CR の「変わる既存のテスト」に書いた test_cr_1179::test_no_dead_on_row_with_alien の 1 件だけ。SCRIPT ERROR は 0 件。
- test_cr_1051 が 1 件落ちたことがあったが、写しを同時に流して保存のファイルを取り合ったため。1 つだけで流し直すと通った。

## 迷った点と提案
1. **3 本に分けた**: 規則と表示を分けるため。
2. **答えと合う組に限らない**: 赤くない宇宙人 1 つなら鳴らす。答えを知らせないため。
3. **line の手には振動を足していない**: そのため × の 15 ms・宇宙人の 30 ms が line の手で消え、test_cr_1179 の 1 つの振動の期待値が変わる（[30, 15, 15, 15] は [30, 15, 15] に、[30, 15, 15, 15, 15, 250] は [30, 15, 15, 15, 250] に）。line の手でも元の振動を出す案は、Pixel の手触りを見てから別の CR で。
4. **dead と同じ手なら dead を先**: そろった組は覚えるだけで、あとで鳴らさない。
5. **1 マスだけの区域**: 宇宙人を置くだけでそろって line が鳴る（最初の面の (3, 1)・(0, 2)）。
6. **光**: 白・不透明度 0.5・0.3 秒。明るい区域で見えにくければ、色と長さを直す。
7. **test_cr_1179 は draft/cr1179 の probe の形で見た**: 1179 の run が作った実際のテストに合わせて、「変わる既存のテスト」を書き写すこと。
8. **origin の user_text**: ユーザーの言葉が無いので、依頼の題を入れた。差し替えてほしい。
