直した

# 手触りの 2 本目（line）の依頼の「変えること」の見直し（10/27、クラウドセッション）

1183（規則）の R0' の NG を受けて、3 本の依頼の「変えること」を見直した。見たのは、CR に写らない頭の段落を「上の」などで指していないか。

- branch: draft/line
- 直したファイル: drafts/req_line_rules.txt（「変えること」だけ。確かめる項目・YAML の欄は変えていない）
- drafts/req_line_sound.txt: **直す所なし**。4 行とも、決まりを箇条の中に書いている。
  - 「チュートリアルでなければ Rules.filled_lines(...)、チュートリアルなら []」
  - new_lines の作り方
  - 「sfx_name が "clear"・"place"・"mark" のどれかで、last_snapshot が空でなく、new_lines が空でなければ "line" にする」
  - 頭の段落を指す言い方は無い。
- drafts/req_line_flash.txt: **直す所なし**。5 行とも、値と手順を箇条の中に書いている。
  - LINE_FLASH_TIME、flash_lines・flash_alpha の中身、_draw・_process の条件、line の手で flash_lines(new_lines) を呼ぶこと。
  - 頭の段落を指す言い方は無い。

## req_line_rules.txt の「変えること」の新しい文（全文、4 行）
```
- core/rules.gd に static func filled_lines(board_state, level) -> Array を足す。board_state か level が null なら [] を返す。
- filled_lines は、行（y ごと）・列（x ごと）・区域（区域の番号ごと）のそれぞれについて、小惑星とレーダーのマスを除いたマスが全部「宇宙人」か「×」で、宇宙人がちょうど 1 つあり、その宇宙人が Rules.conflicts(board_state, level) の中に無い組だけを返す。空のマスが 1 つでも残る組、宇宙人が 0 個か 2 つ以上の組、宇宙人が赤い組は入れない。
- 返す組は辞書 {"kind": 種類, "index": 番号, "cells": マスの並び}。種類は行が "row"（番号は y）、列が "column"（番号は x）、区域が "region"（番号は区域の番号）。マスの並びは小惑星とレーダーのマスを除き、y の小さい順、y が同じなら x の小さい順。組の並びは行（y の小さい順）→ 列（x の小さい順）→ 区域（番号の小さい順）。
- Rules.conflicts、Rules.dead_marks、ほかの規則の関数、ほかのファイルは変えない。
```
- 前の文（1 行目）は「core/rules.gd に static func filled_lines(board_state, level) -> Array を足す。上の「そろった組」を、上の並びの辞書の並びで返す。board_state か level が null なら [] を返す。」だった。
- 4 行なので、5 行の決まりに収まる。最後の行は「〜・ほかのファイルは変えない」。本文に「のまま」「重な」、assets の道、assert_ は無い（機械で確かめた）。

## 気づいたこと（直していない）
- draft/line の下書きは、1179〜1182 が main に入る前に、見本のテスト（draft/cr1179・draft/cr1180 の probe）で書いた。
  - 音の CR の「変わる既存のテスト」は、仮の名前 test_cr_1179.gd::test_no_dead_on_row_with_alien と見本の値で書いてある。
  - 実際の main b50af7e では、名前は test_cr_1179_main_dead_with_alien（値は下書きと同じ 15・250 の形）。
  - 音の CR を作る前に、名前を実際のテストに合わせて直す必要がある。頼まれれば直す。
