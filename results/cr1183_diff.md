差分 OK

# InvaderRadar改修1183 の差分（cr/1183-safe-apply fa20191 と main b50af7e）の見立て

merge-base は b50af7e。commit は fa20191 の 1 つ。依頼と CR は branch review/cr1183-r0p-2 の briefs/ir_cr1183_r0p2.md、R3' は review/cr1183-r3p-2 の results/cr1183_r3p_2.md と読み比べた。「そろった」の決め方は、下書きどおり（答えとは比べない）で読んだ。

## 1. 変わったファイル
- 変わったのは core/rules.gd（+129、末尾に足しただけ）と test/cr/test_cr_1183.gd（新しい）だけ。
- scenes/・game/・ほかの core/ のファイル、既存のテストは変わっていない。.uid も無い。
- test_cr_1183.gd は、R3'（2 回目）の材料と 1 文字も違わない。

## 2. core/rules.gd の filled_lines
- 既存の関数（conflicts・is_solved・radar_count・radar_conflicts・radar_satisfied・dead_marks）は 1 行も変わっていない。dead_marks の後に filled_lines を足しただけ。
- 依頼の決まりとの突き合わせ（BoardState の EMPTY = 0・MARK = 1・PIECE = 2 で読んだ）:
  - board_state か level が null なら []。依頼どおり。
  - 小惑星（level.asteroids）とレーダー（level.radar の [x, y]）のマスは、状態を見る前に continue で飛ばし、cells にも入れない。依頼どおり。
  - 空のマス（0）が 1 つでもあれば valid = false で、その組は入れない。依頼どおり。
  - × と宇宙人だけで埋まり、宇宙人がちょうど 1 つ（alien_count == 1）で、その宇宙人が conflicts(board_state, level) の中に無い組だけを入れる。宇宙人 0 個（× だけ）・2 つ以上・赤い宇宙人は入れない。依頼どおり。
    - conflicts は 1 回だけ呼び、辞書にして引く。
  - 辞書 {"kind", "index", "cells"}。行は "row"・y、列は "column"・x、区域は "region"・区域の番号。依頼どおり。
  - cells の並び:
    - 行は x の小さい順。
    - 列は y の小さい順。
    - 区域は y の外側・x の内側の二重の繰り返しなので、y の小さい順、同じ y なら x の小さい順。
    - 依頼どおり。
  - 組の並び: 行（y 順）→ 列（x 順）→ 区域（0 から region_count() - 1）。依頼どおり。
  - 区域の内側の break は x の繰り返しだけを抜けるが、外側に `if not valid: break` があるので正しく止まる。
- 区域の番号の数え方: range(level.region_count()) は、番号が 0 から連続している前提。番号が飛んでいる面では、大きい番号の区域が見られない。
  - 既存の dead_marks と同じ作りで、今のデータは 0 から連続している。依頼の外の話なので NG にはしない。

## 3. 下書きの try_line_patch.py の rules() との比べ
結果は同じ。違いは書き方だけで、依頼の決まりから外れる所は無い。

- 置き場所: 下書きは dead_marks の前、branch は dead_marks の後（ファイルの末尾）。振る舞いは同じ。
- 組の作り方: 下書きは先に全部の組のマスの並びを作ってから 1 つの繰り返しで調べる。branch は行・列・区域の 3 つの繰り返しを書き下している。並びも結果も同じ。
- 空のマス: 下書きは最後まで見て filled = false、branch はそこで break。どちらもその組は入れない。
- 赤い宇宙人: 下書きは conflicts の Array に has。branch は辞書にして has（速い）。
- 小惑星・レーダーの判定: どちらも状態を見る前に飛ばす。小惑星やレーダーのマスに宇宙人があっても数えない点も同じ（その宇宙人は conflicts に入る。そのマスを除いた組の宇宙人の数で決まる）。
- 小惑星・レーダーだけの組（数えるマスが 0）: どちらも宇宙人 0 個なので入れない。

## 4. 計算の重さ
- 1 回の呼び出しでしていること:
  - conflicts（宇宙人 n 個の組み合わせで n²/2 回の比べ）を 1 回。
  - 行と列で W×H を 2 回。
  - 区域で region_count × W×H 回の region_at を見る。
  - マスごとの小惑星・レーダーの判定は、それぞれの並びを全部見る。
- 盤の大きさ: sound.gd の bgm_for_size は 10 以上も見ているので、大きい盤を 10×10（区域 10、宇宙人 10、小惑星・レーダー合わせて 10 程度）とする。
  - 区域の region_at が約 1,000 回。
  - 小惑星・レーダーの判定が約 300 回 × 並びの長さ（約 10）＝約 3,000 回の比べ。
  - conflicts は約 45 組。
- 全部で数千回の簡単な処理なので、GDScript でも 1 回 1 ミリ秒を十分下回る見込み（手元に Godot が無く、測ってはいない）。
- 1 手ごと（_refresh ごと）に 1 回呼んでも重すぎない。
- 盤がさらに大きくなって気になったら、次のようにすれば軽くできる。今は要らない。
  - 区域のマスの一覧を 1 回で作る（region_count × W×H を W×H にする）。
  - 小惑星・レーダーを辞書にする。
