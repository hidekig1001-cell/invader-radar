差分 OK

# InvaderRadar改修1181 の差分（cr/1181-safe-apply 50ce932 と main a12daf1）の見立て

merge-base は a12daf1。commit は 50ce932 の 1 つ。依頼と CR は branch review/cr1181-r0p の briefs/ir_cr1181_r0p.md、R3' は review/cr1181-r3p の results/cr1181_r3p.md と読み比べた。

## 1. 変わったファイル
- 変わったのは scenes/main.gd（+2）と test/cr/test_cr_1181.gd（新しい、+97）だけ。.uid も含めて、ほかのファイルは無い。
- 既存のテストは書き換わっていない（依頼の「変わる既存のテスト: なし」と合う）。
- test_cr_1181.gd は、R3' の材料と 1 文字も違わない。

## 2. main.gd
- _refresh の play_sfx の後の if/elif の最後（dead の vibrate(120) の後）に、elif sfx_name == "wrong": sound.vibrate(250, 0.3) を足しただけ。依頼どおり。
- 変わっていないもの:
  - place（30）・mark（15, 0.4）・dead（120）の振動。
  - dead を鳴らす決まり（curr_dead・last_dead と "mark" → "dead" の差し替え）。
  - 1178 のお知らせの待ち（size_up_wait など）。
  - sound.gd・Sound.sfx_for。

## 3. 依頼に無い副作用
a12daf1 の Sound.sfx_for（level_clear > wrong > hint > clear > place > mark）で読んだ。

- ぶつかった宇宙人を取る手: conflicts は減り、宇宙人の数も減るので "clear"。振動しない（CHECK 2）。
- 宇宙人を置いてぶつかる手: "wrong" が place より先なので、30 は出ず 250 だけ（CHECK 1・3）。
- ヒント: ヒントを出すだけでは conflicts は増えないので "hint"。250 は出ない。
- ANSWER（apply_hint）: 正しい答えを当てる手なので、ふつう conflicts は増えない。もし増えれば "wrong" で 250 が出るが、それは依頼の「sfx_for が wrong を返す手」の決めのとおり。
- 面の切り替え: 前の状態は cleared で新しい盤の conflicts は 0、前の手より増えないので wrong にならない。250 は出ない。
- チュートリアルの切り替え: start_tutorial・end_tutorial で last_conflicts を入れ直すので、切り替えでは出ない。チュートリアルの盤でぶつかる手の 250 は依頼どおり。
- 最初の _refresh:
  - last_conflicts は 0 から始まる。ぶつかった宇宙人がある盤（読み直した進み具合）から立ち上げると、今でも "wrong" の効果音が鳴っていて、この CR で 250 の振動も 1 回出る。
  - 依頼の決めのとおりで、CR-1180 の「× のある盤から立ち上げると 15 が出る」と同じ種類の振る舞い。NG にはしない。気になるなら人の確かめで見る。
- wrong と dead が同じ手で起きたとき:
  - dead への差し替えは sfx_name が "mark" のときだけ。wrong の手（宇宙人を置く手）は dead にならず、250 だけが出る。
  - × を付ける手は conflicts を増やさないので、ふつうは同じ手では起きない。
  - last_dead はどちらの手でも curr_dead に入れ直されるので、後の dead の決まりも崩れない。

## 4. InvaderRadar改修1182（dead の vibrate(120) を vibrate(250, 0.3) に）とぶつかるか
- ぶつかる。1182 が a12daf1（1181 の前）を土台に作られると、main.gd の同じ所でぶつかる。1182 が替える `sound.vibrate(120)` の行のすぐ後に、1181 が `elif sfx_name == "wrong":` を足しているため。
- 手元の別の作業木（push しない、後で消した）で試した。a12daf1 で dead の行を vibrate(250, 0.3) に替えた仮の commit に cr/1181-safe-apply を merge すると、scenes/main.gd の _refresh の dead／wrong の所で CONFLICT になった。
- 勧め: 1182 は 1181 を main に入れた後の main を土台に作る。そうすれば、1182 は dead の分かれ道の 1 行を替えるだけで、ぶつからない。
- 1182 の後は dead と wrong が同じ vibrate(250, 0.3) になる。分かれ道をまとめたくなっても、1182 の依頼に無ければ替えないほうがよい。
