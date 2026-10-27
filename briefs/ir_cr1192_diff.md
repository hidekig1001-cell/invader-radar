# クラウドへの依頼: InvaderRadar改修1192 の差分を読む（2026-10-27 19:5x、Invader Radar31）

branch cr/1192-safe-apply と、その土台の main 46fc619（v1.97-cr1188）の差分を読み、依頼どおりかを決めてください。依頼と CR は branch review/cr1192-r0p の briefs/ir_cr1192_r0p.md（R0' OK）、R3' は review/cr1192-r3p の results/cr1192_r3p.md（OK）。アプリのコードは書き換えない。回答とファイルの文は日本語で。
main はその後に 1189（scenes/main.gd）が入って 2f8272f に、1190（game/level.gd）も入る見込みだが、1192 は core/rules.gd だけなので、土台は 46fc619 で読んでよい。

AuteDev の決まり: CR の「変えないこと」にある test/ は機械の決まった欄、tests/ は run の作業フォルダの置き場所（取り込みで test/cr/ へ移る）。どちらも NG の理由にしない。Godot が自動で作る .uid のファイルは NG にしない。

見ること:
1. 変わったのは core/rules.gd・test/cr/test_cr_1192.gd（新しい）だけか。ほかのファイル・既存のテストは変わっていないか。test_cr_1192.gd は R3' で読んだものと同じか。
2. core/rules.gd: dead_marks の行・列・区域の 3 つのループで、岩（is_asteroid・is_radar_cell）の continue を状態の判定より前に移しただけか。状態の見方（宇宙人なら break、× なら足す、空なら break）・返す並び（終わりの並べ替え）を変えていないか。filled_lines・conflicts・ほかの関数を変えていないか。
3. 今の面（岩のマスに宇宙人が置けない、CR-1186）で、画面の × の色（mark_color_at）と dead の音の振る舞いが変わらないか。
4. 下書きの try_dead_marks_order_patch.py（draft/next-a）と比べて、違いがあれば、それが依頼の決まりから外れていないか。

終わりの条件: 結果を branch review/cr1192-diff のファイル results/cr1192_diff.md に書いて commit・push。1 行目は「差分 OK」か「差分 NG: <理由>」。main・ほかの branch には触らない。
