差分 OK

# InvaderRadar改修1179 の差分（cr/1179-safe-apply b92aadd と main e6cf4ca）の見立て

merge-base は e6cf4ca。commit は b92aadd の 1 つ。依頼と CR は branch review/cr1179-r0p の briefs/ir_cr1179_r0p.md と読み比べた。

## 1. 変わったファイル
- scenes/main.gd（+14）、scenes/sound.gd（+3）、test/cr/test_cr_1179.gd（新しい、+169）だけ。
- 既存のテストのファイルは書き換わっていない（依頼の「変わる既存のテスト: なし」と合う）。
- dead.wav は main（1e08e7f で入った assets/audio/dead.wav）のものを preload で使うだけで、assets は変わっていない。
- test_cr_1179.gd の中身は、R3'（review/cr1179-r3p で OK）の材料と 1 文字も違わない。

## 2. sound.gd
- const SFX_DEAD := preload("res://assets/audio/dead.wav") を SFX_BUTTON の後に足した。play_sfx の match の最後に "dead": stream = SFX_DEAD を足した。
- ほかの効果音、sfx_for、vibrate・vibrations は変わっていない。依頼どおり。

## 3. main.gd
- var last_dead: bool = false を last_conflicts の後に足した。
- _refresh: Sound.sfx_for の後で、チュートリアルでなければ curr_dead = not Rules.dead_marks(session.board, session.level).is_empty() とする。sfx_name == "mark" かつ last_snapshot が空でなく、last_dead が false で curr_dead が true なら sfx_name = "dead"。チュートリアル中は curr_dead = false のまま。依頼どおり。
- play_sfx の後: "place" なら vibrate(30)（CR-1177 のまま）、elif "dead" なら vibrate(120)。依頼どおり。
- last_conflicts を入れ直す所（_refresh）で last_dead = curr_dead。依頼どおり。
- 依頼の箇条に名前の無い 2 行がある。どちらも last_snapshot・last_conflicts を入れ直すほかの所なので、依頼の「last_conflicts を入れ直すところで last_dead を入れる」の範囲と読んで、NG にはしない。
  - start_tutorial の last_conflicts の後に last_dead = false。
  - end_tutorial の last_conflicts の後に last_dead = not Rules.dead_marks(session.board, session.level).is_empty()。
  - 振る舞いの面でも正しい。end_tutorial で本当の盤の状態を入れるので、チュートリアルの前から × だけの組があった盤に戻っても、次の × で誤って dead が鳴らない（「空から空でなくなった瞬間だけ」の決まりのとおり）。CHECK 8 は、戻った盤が空なので last_dead = false で通る。
- そのほか、余計な変更は無い（吹き出しの文・help_text・dead_marks_text は変わっていない）。

## 4. 依頼に無い副作用
- place の 30 ms 振動: if/elif なので変わらない。dead は mark の差し替えだけなので、place・wrong・hint・clear・level_clear の手で鳴ることは無い（順 level_clear > wrong > hint > clear > place > dead > mark のとおり）。
- 最初の _refresh（_ready、94 行目）: last_snapshot が空なので dead に差し替えない。last_dead にはその時の盤の状態が入る（CHECK 7 の筋）。
- チュートリアル: curr_dead は false のまま、差し替えも振動も無い。start と end での last_dead の入れ方は上のとおり。
- ヒント・ANSWER: apply_hint などで × だけの組ができても、sfx_for が "mark" 以外を返す手は差し替えない。last_dead だけが入れ直されるので、後の手で二重に鳴ることは無い。
- swipe（CHECK 5）: session.swipe は全部のマスに × を付けてから _commit を 1 回だけする。changed も 1 回なので、_refresh は 1 回で "mark" → "dead" になり、振動は [120] の 1 回。
- 面の切り替え（CHECK 6）: next_level の changed で _refresh が走り、新しい面の盤は空なので curr_dead = false → last_dead = false。2 つ目の面で組ができたときに再び鳴る。

## 5. 今の main（05834fd、v1.87-cr1178）と merge したときの見立て
- 手元の別の作業木（push しない、後で消した）で `git merge --no-commit --no-ff origin/cr/1179-safe-apply` を試した。ぶつかりは無く、自動で merge できた（変わるのは上の 3 ファイルだけ）。
- main.gd の _refresh で、1179 の dead の差し替え・振動・last_dead は上の方（効果音の所）、1178 の size_up_wait = 0.6 は下の方（cleared_text を消す所）にあり、別々の行。merge の後の _refresh も、両方がそのまま並んでいるのを読んで確かめた。
- 絡み:
  - 1178 の待つ 0.6 秒の間と、お知らせが出て 0.8 秒たつまでの間は、_on_touch_down が _stroke = [] の後に return する。この間はタップもスワイプも盤に届かず（_on_touch_up は _stroke が空で return）、× が付かないので、dead が鳴ったり振動したりすることは無い。
  - 面の切り替えの _refresh で last_dead = false になる（新しい盤は空）。お知らせを消した後の最初の × だけの組で、普通に dead が鳴る。
  - 1178 は効果音・振動に触っていない。1179 は bubble・size_up_* に触っていない。おかしく絡む所は見つからなかった。
- merge の後のテスト（test_cr_1178・test_cr_1172・test_cr_1179）は手元で実行していない（Godot が無い）。上は読んでの見立て。
