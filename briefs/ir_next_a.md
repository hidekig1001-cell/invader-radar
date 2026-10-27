# クラウドへの依頼: InvaderRadar の次の改修 2 本の調べと依頼の下書き（A 組）（2026-10-27 18:2x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar。main は 1188 の取り込み中（入れば v1.97-cr1188。入るまでは 9193cdf v1.96-cr1186 を土台に読んでよい。1188 は scenes/message_bubble.gd と main.gd の tick_size_up だけを変える）。アプリのコードは main に書き換えない。回答とファイルの文は日本語で。
ユーザーの指示（10/27 18:2x）: 「pixelの確認はもっとまとめて行いたいから改修の実装進めていって」。見た目の好みの選びが要らない、不具合の芽・片づけを先に進める。

## 下書きしてほしい改修
1. **使われない last_dead を消す**（1187 の差分の読みで見つかった。scenes/main.gd の宣言・_refresh・start_tutorial・end_tutorial の 4 か所で書くだけで、どこも読まない）。あわせて test/cr/test_cr_1187.gd の CHECK 3（test_cr_1187_undo_dead_group）に残る、テスト作成役の迷いの英語のコメント 8 行ほど（「Or whatever sfx …」「Wait, prompt says …」など）を消す。振る舞いは変えない。
2. **Rules.dead_marks の判定の順を filled_lines に合わせる**（前の調べ results/bug_dead_radar.md の「ついでに見つけたこと」）。dead_marks は、小惑星・レーダーのマスの宇宙人を「宇宙人がいる」と数える（状態の判定が岩の判定より先）。filled_lines は岩の判定が先で数えない。dead_marks も岩のマスを先に除く形にそろえる。1186 で新しく岩に宇宙人は置けないが、古いセーブの盤では起きうる。

## してほしいこと
- それぞれ、今の作りを短く確かめ、依頼の下書きを、これまでの依頼（例: draft/bug-dead-radar の drafts/req_bug_radar_block.txt）と同じ形で書く。
- 決まりは「変えること」の箇条の中に書く（「上の」で頭の段落を指さない）。確かめる項目は、期待値を値まるごとで書き、小数には誤差を書く。[] にしないものは「〜は [] にしない」と書く。テストの関数で、まだ無い関数を呼ぶときは、ファイルの頭の preload の const からではなく、関数の中の load で呼ぶ形を指示する（1188 で、preload の const から無い静的関数を呼んでファイルごと Parse Error になり、直しなしで赤くならなかった）。
- 変わる既存のテスト・変わらない既存のテストは main の実際のテスト名で書く。依頼の検査（R-C28）は、依頼が変える関数・値を確かめている既存のテストがどちらにも無いと error にするので、漏れなく挙げる。
- 1 は「振る舞いを変えない片づけ」なので、確かめる項目は、変数が無くなったこと（例: "last_dead" in m が false）と、1187 の dead の振る舞いが今のまま（2 つ目の組でも鳴る）ことを確かめる形にする。テストのコメントを消す所は、変わる既存のテストとして書く（表明は変えない）。
- probe の .gd と、当て試しの直し try_<名前>_patch.py も書き、main の写しで、直しを当てて通ること・直しなしで probe が落ちることを確かめる（Godot があれば）。

## 終わりの条件（必ず守る）
- この branch（draft/next-a）に、drafts/req_cleanup_last_dead.txt・_probe.gd・try_cleanup_last_dead_patch.py、drafts/req_dead_marks_order.txt・_probe.gd・try_dead_marks_order_patch.py と、results/next_a.md（2 本の要約と当て試しの結果）を置いて commit・push する。results/next_a.md の 1 行目は「2 本: last_dead の片づけ <当て試しの一言>／dead_marks の順 <当て試しの一言>」。main・ほかの branch には触らない。
