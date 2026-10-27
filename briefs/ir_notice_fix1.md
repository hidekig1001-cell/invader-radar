# クラウドへの依頼: InvaderRadar改修1188（お知らせを金色の札に、案 A）の依頼の下書きを、依頼の検査が通るように直す（2026-10-27 16:4x、Invader Radar30）

リポジトリ hidekig1001-cell/invader-radar の branch draft/notice。main は 0ae3435。アプリのコードは main に書き換えない。回答とファイルの文は日本語で。
ユーザーの判断 D-20261027-1615＝A（金色の札がぽんと弾む）。手元では drafts/req_notice.txt を req_cr1188.txt（probe は req_cr1188_probe.gd、origin の decision を D-20261027-1615 に直した）にして当て試しを流した。直しを当てた版は 743 件すべて通り、直しなしは probe の 5 件だけが落ちた。しかし依頼の検査（reqcheck）が error で止まった。

## 依頼の検査の error（原文）
```
1. [error] R-C28（依頼の 16 行目）: 依頼が変える関数・値を確かめている既存のテストが、依頼の『変わる既存のテスト』『変わらない既存のテスト』のどちらにもありません: test/cr/test_cr_1135.gd::test_cr_1135_bubble_geometry_and_font、test/cr/test_pixel_1023.gd::test_pixel_1023_fit_font_size。どちらかに挙げてください。（C28 の当たりの理由: test_cr_1135.gd:8 が clear_text のテーマ（get_theme_font_size(…）を確かめている；test_pixel_1023.gd:58 が fit_font_size のテーマ（get_theme_stylebox(…）を確かめている）
3. [error] R-RED（依頼の 32 行目）: 見本のテスト（req_cr1188_probe.gd）: CHECK 4: 宣言どおりの形で中身のない版（戻り値が空・null 相当）に対して、表明で落ちる関数がありません（関数: test_clear_text_after_size_up）。ただし、正しい実装で CR の期待値どおりになる表明だけを書いてください。（R3 と同じ雛形＝宣言どおりの形で中身のない版に当てた結果。依頼の項目を、変更で初めて成り立つ形（成功の道と失敗の道の対など）に直すか、見本を項目どおりに直す）
```

## してほしいこと
1. R-C28: test_cr_1135_bubble_geometry_and_font と test_pixel_1023_fit_font_size が、案 A の直しで変わるか変わらないかを読み、「変わらない既存のテスト」（理由つき）か「変わる既存のテスト」（どの表明がどう変わるか）に足す。当て試しでは 2 つとも通っているので、変わらないの見込み。
2. R-RED: 確かめる項目 4（clear_text の後の戻し）を、中身の無い版（show_size_up が何もしない・size_up_mode を立てない版）でも成り立ってしまわない形に直す。例: 項目 4 の中で、まず show_size_up の後に size_up_mode が true・地の色が金色になることを表明し（中身の無い版はここで落ちる）、そのあと clear_text で false・ピンクに戻ることを表明する、など。期待値は値まるごと、小数には誤差。probe も同じに直す。
3. 直した下書きで、main の写しに try_notice_patch.py を当てて全部通ること、直しなしで probe が落ちることを確かめる（できる範囲で。Godot が無ければ、そう書く）。

## 終わりの条件（必ず守る）
- 同じ branch（draft/notice）の drafts/req_notice.txt・drafts/req_notice_probe.gd を直して（try_notice_patch.py も要れば）commit・push し、results/notice_fix1.md に何をどう直したかを書く。1 行目は「直した: R-C28 <足した節>／R-RED <項目 4 の直し方の一言>」。main・ほかの branch には触らない。
