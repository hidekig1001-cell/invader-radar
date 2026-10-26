# クラウドへの依頼: InvaderRadar改修1183 の差分を読む（2026-10-27 06:3x、Invader Radar29）

branch cr/1183-safe-apply と、その土台の main b50af7e（v1.91-cr1182）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1183-r0p-2 の briefs/ir_cr1183_r0p2.md、R3' は review/cr1183-r3p-2 の results/cr1183_r3p_2.md（OK、1 回目は差し戻し）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
「そろった」の決め方（答えと比べるか）はユーザーの判断待ち（D-20261027-0545、推奨は「答えとは比べない」）。差分は下書きどおりの決め方で読んでよい。main への取り込みは判断の答えの後にする。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは core/rules.gd と test/cr/test_cr_1183.gd（新しい）だけか。scenes/ などほかのファイル、既存のテストは変わっていないか。test_cr_1183.gd は R3'（2 回目）で読んだものと同じか。
2. core/rules.gd: static func filled_lines(board_state, level) -> Array が依頼の決まりどおりか（null なら []、小惑星とレーダーのマスを除く、宇宙人ちょうど 1 つで Rules.conflicts に無い、空が残る組は入れない、辞書の形と kind の名前、cells と組の並び）。ほかの規則の関数（conflicts・dead_marks など）を変えていないか。
3. 下書きの try_line_patch.py の rules() と比べて、違いがあれば、それが依頼の決まりから外れていないか。
4. 計算の重さ（盤が大きい面で、1 手ごとに呼んでも重すぎないか）の見立て。

終わりの条件: 結果を branch review/cr1183-diff のファイル results/cr1183_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
