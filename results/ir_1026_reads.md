# IR の読み 3 つ（2026-10-26、main 8b632f5）

## 読み 1: CR-1176 の差分（cr/1176-safe-apply、7d433c0）
差分 OK
- merge-base は main（8b632f5）。変わったのは export_presets.cfg の 1 行と新しいテスト test/cr/test_cr_1176.gd だけ。
- export_presets.cfg は末尾の permissions/internet=true の後に permissions/vibrate=true を 1 行足しただけ。main の節は [preset.0]（1 行目）と [preset.0.options]（13 行目）の 2 つなので、足した行は [preset.0.options] の中。internet・name・platform・ほかの行は変わっていない。
- テストは ConfigFile で load が OK、preset.0.options の permissions/vibrate と permissions/internet が true を確かめていて、依頼どおり。

## 読み 2: CR-1177 の差分（cr/1177-safe-apply、01bd9e0）
差分 OK
- 変わったのは scenes/sound.gd（+5）、scenes/main.gd（+2）、新しいテスト test/cr/test_cr_1177.gd だけ。
- sound.gd: var vibrations: Array = [] と、func vibrate(ms: int) -> void（vibrations.append(ms) の後に Input.vibrate_handheld(ms)）を足しただけ。play_sfx・sfx_for・play_music は変わっていない。
- main.gd: _refresh の `if sfx_name != "":` の中、sound.play_sfx(sfx_name) の後に `if sfx_name == "place": sound.vibrate(30)` を足しただけ。mark・clear・level_clear・wrong・hint では振動しない。効果音の選び方と鳴らし方、駒の弾みは変わっていない。
- チュートリアル: _refresh はチュートリアルでも呼ばれるので、チュートリアルで宇宙人を置いたときも振動する。依頼は _refresh の中で place なら振動と書いているのでこれは依頼どおり。効果音の鳴り方は変わらない。
- テストは CHECK 1（sound.vibrate(30) で [30]）と CHECK 2（double_tap で置くと [30]、tap の × では [30] のまま）。依頼どおり。

## 読み 3: CR-1178 の R3'（tests/test_cr_1178.gd と test_cr_1172 の書き直し）
R3' NG: test_cr_1172 の書き直しが依頼の「tick_size_up の行を足すだけで表明は変えない」を越えて表明（assert_eq(m.size_up_wait, 0.6) など）と 2 回目のタップを足しており、その assert_eq は await wait_frames(1) の後なので _process の tick_size_up(delta) で 0.6 から減っていて落ちる
- 新しいテスト test_cr_1178: 依頼の確かめる項目 1 の手順と期待値（level_index 1、tile_mode false、size_up_wait 0.6、tick_size_up(0.7) の後 tile_mode true と 5×5 の文、すぐのタップで tile_mode true のまま、tick_size_up(1.0) とタップの後 tile_mode false と bubble.text == m.help_text()）はすべて写っている。間に await が無いので _process が割り込まず、size_up_wait の 0.6 の比べも成り立つ。違いは、依頼の「関数の中で load()」がファイルの頭の preload の const になっている点だけで、中身は同じ（大きな問題ではない）。
- 今の main では m.size_up_wait・m.tick_size_up が無いので、このテストは落ちる（CR の前で落ちる筋は満たす）。
- test_cr_1172_size_up_tile_ja の書き直し:
  - 依頼は「s.next_level() と await wait_frames(1) の後に m.tick_size_up(0.7) を足し、m._input(down) の前に m.tick_size_up(1.0) を足す。表明は 1 つも変えない」。
  - 実際は 24 行目の後に assert_eq(m.size_up_wait, 0.6) と assert_false(m.bubble.tile_mode) の 2 つの新しい表明を足している。
  - main の _process（515 行目）はチュートリアルでもルール画面でもなければ毎フレーム回り、CR で session.tick の前に tick_size_up(delta) が入る。next_level の _refresh で size_up_wait = 0.6 になった後、await wait_frames(1) の 1 フレームで 0.6 - delta になるので、assert_eq(m.size_up_wait, 0.6) は落ちる。
  - m.tick_size_up(1.0) は、元の m._input(down) の前ではなく、元のタップと await の後に assert_true(m.bubble.tile_mode)・m.tick_size_up(1.0)・2 回目の m._input(down)・await wait_frames(1) をまとめて足す形。依頼に無い表明と操作が増えている。
- test_cr_1172_size_up_tile_en の書き直し: 依頼は m.tick_size_up(0.7) の 1 行だけ。実際は ja と同じ 3 行（assert_eq(m.size_up_wait, 0.6)、assert_false(m.bubble.tile_mode)、tick_size_up(0.7)）で、size_up_wait の表明が同じ理由で落ちる。
- 直し方の案: 2 関数とも足した assert_eq(m.size_up_wait, 0.6) と assert_false(m.bubble.tile_mode) を除く。ja は依頼どおり元の m._input(down) の前に m.tick_size_up(1.0) を 1 行足すだけにし、足した assert_true・2 回目の _input・await を除く。
