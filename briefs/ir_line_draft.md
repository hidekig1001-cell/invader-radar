# クラウドセッションへの依頼: IR 手触りの 2 本目（そろったら line の音と光）の調べと依頼の下書き（2026-10-27 03:1x、Invader Radar29）

- repository: hidekig1001-cell/invader-radar（private）、土台は main（05834fd、v1.87-cr1178）
- 成果物は branch `draft/line` の `drafts/` に push。main・ほかの branch には触らない。
- 結果の要約は `results/line_draft.md` にして同じ branch に push（ローカルからはクラウドの返答が読めない。push が無いと終わったと分からない）。

## 依頼の文

リポジトリ hidekig1001-cell/invader-radar の main（v1.87-cr1178、05834fd）を土台に、手触りの 2 本目「行・列・色（区域）がそろったら line の音と光」の依頼の下書きを作り、branch `draft/line` に commit して push してください。main・ほかの branch には触らないこと。回答とファイルの中の文は日本語で。

### 前提（このあと main に入る予定の改修。下書きはこれらが入った後を土台にする前提で書く）
- InvaderRadar改修1179: × だけの組（core/rules.gd の Rules.dead_marks）が空から空でなくなった瞬間に dead の音と 120 ms 振動。中身は branch `draft/cr1179` の drafts/（req_cr1179.txt・try_1179_patch.py）。
- InvaderRadar改修1180〜1182: 振動の強さ（sound.vibrate に amplitude の引数）と、× を付けたとき 15 ms、宇宙人がぶつかったとき 250 ms、× が赤くなるとき 250 ms。branch `draft/cr1180` の drafts/。
- 効果音 line.wav は main に入っている（v1.84-sfx、assets の audio のフォルダ）。scenes/sound.gd から使われているかは調べて notes に書く。

### 中身
- 「そろった」は、行・列・色（区域）のどれかが「宇宙人 1 つと × だけ」で埋まりきった（空のマスが無くなった）瞬間、と読む（10/26 の解釈）。正しく置けた組（答えと合う）に限るか、宇宙人が 1 つなら答えと合わなくても鳴らすかは、今のルール（core/rules.gd・game/session.gd）を読んで notes で提案する。
- その瞬間に効果音 `line` を鳴らし、そろった組のマスを短く光らせる（例: 0.3 秒ほど明るくして戻す。scenes/board_view.gd の今の描き方・CR-1169 の「置いたとき弾む」の仕組みに合わせる）。光の記録をテストから読めるように、例えば board_view に `var flashes: Array = []` のような記録を足す案を出す。
- 増えたとき（2 つ目の組がそろった）にも鳴らすか、面のクリア（level_clear）と同時のときはどちらを優先するか、dead・place・mark との順（Sound.sfx_for）を notes で決めて書く。
- 1 本の CR に入りきらなければ（変えることは 5 行まで）、「音」と「光」の 2 本に分けた案にする。

### 作るもの（branch draft/line の `drafts/` の下）
1. `drafts/req_line.txt`（2 本に分けるなら req_line_sound.txt・req_line_flash.txt）— CR 作成の依頼。形は draft/cr1179 の drafts/req_cr1179.txt と同じ（日本語の本文、「確かめてほしいこと」、「変わる／変わらない既存のテスト」、`## 依頼の欄（YAML）`）。
2. `drafts/req_line_probe.gd` — 確かめる項目をそのまま GUT にした見本（extends GutTest、`## CHECK: <番号>` を関数の直前に）。
3. `drafts/try_line_patch.py` — main の写しの中で流すと依頼どおりに直る Python の台本（文字列を assert つきで置き換える形。1179・1180 の直しが無ければ先に当てる）。
4. `drafts/notes_line.md` — 調べたこと（どの関数を直すか、影響を受けそうな既存のテスト、迷った点と提案）。

### 依頼の書き方の決まり（守らないと AuteDev の依頼の検査で止まる）
- 「変えること」の箇条は 5 行まで。最後の 1 行は「〜・ほかのファイルは変えない」。
- 「〜のまま」と書かない（R-C10）。「重な」「overlap」を書かない（C29）。本文に assets/… の道をそのまま書かない（C25）。
- 確かめる項目にコード（assert_… など）を書かない（C61）。今のコードでも成り立つ値・今のコードにある文字列をそのまま期待値にしない（C19。m.help_text() のような式にする）。確かめる項目の文の中に YAML の `target` の式が入っていること（C66）。
- `_` で始まる名前は decls に書けない（C18）。アプリのコードで `Time.` は使えない。
- 確かめる項目には、その決まりを使う場合を必ず入れる（宇宙人が 2 つの組はそろわない、空のマスが残る組は鳴らない、× を消して戻してから再び埋めたら再び鳴る、など）。
- 何を数えるか・数えないか・向きを、あいまいさなく書く。「その行のほかの区域」のような言い方は避け、例を付ける。
- 「変わる既存のテスト」は表明の式の置き換え「A は B に変わる」で書く。「変わらない既存のテスト」には、直す関数や効果音の選び方を見ている既存のテスト（test/ を grep：sfx_for、play_sfx、played、vibrations、_refresh、dead_marks）を `test/…/ファイル.gd::関数名 — 理由` で挙げる。
- AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。
- 依頼の欄の changes は AuteDev の形（`- file: scenes/sound.gd / func: vibrate / add_params: [{name: amplitude, type: float, default: -1.0}]`）。

### 終わりの条件
- drafts の 4 つと results/line_draft.md を branch draft/line に push した。Godot が使えるなら、try_line_patch.py を main の写しに当てて probe と既存のテストを流し、結果を notes に書く（使えなければ「流していない」と書く）。
- results/line_draft.md に、branch 名・commit・確かめる項目の要約・迷った点と提案を書く。
