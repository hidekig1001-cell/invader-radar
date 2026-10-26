# クラウドセッションへの依頼: IR CR-1176 の R3'（テストを読む）（2026-10-26 20:2x、Invader Radar改修28）

## 依頼の文
リポジトリ hidekig1001-cell/invader-radar の main（8b632f5）を読める状態で、下の「依頼の確かめる項目」と、改修 run が作った「新しいテスト」を読み比べ、R3'（テストの確認）の OK／NG を決めてください。アプリのコードは書き換えないこと。回答は日本語で。

### AuteDev の決まり（読み違えないために）
- 下の「新しいテスト」の見出しの `tests/test_cr_1176.gd` は、改修 run の作業フォルダの中の置き場所。取り込むときに AuteDev が `test/cr/` へ移す。置き場所は NG の理由にしない。
- 振動の許可は、改修 run が依頼の settings の行を機械で export_presets.cfg に当てる（R4 の前）。テストはその後の export_presets.cfg を読む。

### 見ること
1. CHECK の関数が、依頼の項目の手順と期待値をそのまま写しているか。足りない手順・違う期待値・余計な表明が無いか。
2. 期待値が今の main でも成り立ってしまわないか（main の export_presets.cfg の [preset.0.options] に permissions/vibrate があるか読む）。
3. 既存のテストの書き直しは無い（依頼も「変わる既存のテスト: なし」）。

### 終わりの条件（必ず守る）
- 結果を、同じ branch `review/cr1176-r3p` のファイル `results/cr1176_r3p.md` に書いて commit・push する。1 行目は「R3' OK」か「R3' NG: <理由>」、続けて項目ごとの見立てを短く。main・ほかの branch には触らない。
- 最後の返答にも同じ 1 行目を書く。

## 依頼の確かめる項目
1. テストの関数の中で var cf = ConfigFile.new() とし、cf.load("res://export_presets.cfg") は OK。cf.get_value("preset.0.options", "permissions/vibrate") は true で、cf.get_value("preset.0.options", "permissions/internet") は true。

## 新しいテスト
== tests/test_cr_1176.gd
extends GutTest

## CHECK: 1
func test_vibrate_permission_is_true() -> void:
	var cf = ConfigFile.new()
	assert_eq(cf.load("res://export_presets.cfg"), OK)
	assert_eq(cf.get_value("preset.0.options", "permissions/vibrate"), true)
	assert_eq(cf.get_value("preset.0.options", "permissions/internet"), true)
== 既存のテストの書き直し
== 終わり
