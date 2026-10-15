# このアプリの補足（author）

- このゲームの決まりと今ある画面は SPEC.md の「0. ゲームの決まり」に書いてある。ルール・操作・目的を CR に書くときは、そこに書いてあることだけを使う（ほかのパズルの決まりを持ち込まない）。
- 画面の文字: HUD・ボタン・吹き出しなど今ある文字は英語（"LEVEL"・"SCORE"・"HINT"・"UNDO"・"HOW TO PLAY" など）。日本語も出せる（日本語は端末のフォントで出ることを CR-1025 の起動画面で実機で確かめた）。起動画面（`scenes/title_screen.gd`）は言語の選択（"English"・"日本語"）のあとに、英語なら "START WITH TUTORIAL"・"START NOW"、日本語なら "チュートリアルから始める"・"すぐに始める" の 2 つのボタンを出す。期待値の文字列は、依頼で変わる値（依頼の文言）を書く。今のコードの文字列をそのまま期待値にしない。
- 画面に文字を出す CR では、文字を値まで決めた定数（`const X := "..."`）を確かめる項目にしない（雛形にも同じ値が入るので R3 で止まる）。確かめるのは、画面のノード（例: `scenes/main.tscn` を立ち上げた `main` の子のラベル）の `text` が決まった文字列と同じこと、またはラベルが見えること（`visible`）・盤と重ならないこと（`get_global_rect()` が `board_view.board_rect()` と交わらない）にする。
- 規則（core/）と表示（scenes/）は 1 つの CR で両方を変えない。表示の CR は、`session` や `Rules` の関数を読むだけにする。
- 盤の場所は `scenes/board_view.gd` の `AREA`（1080×1920 の画面で Rect2(40, 480, 1000, 1000)）。盤の上は 480 まで HUD と吹き出し、盤の下は 1480 から下が空いている（HINT のボタンがある）。
- 決まり・操作・画面の言葉（HELP_TEXT、ルールの説明、ヒントの言葉など）を変える CR は、チュートリアルの段のデータ `game/tutorial_steps.gd`（CR-1011 から）の文と手順も同じ CR で直す。対象の候補に `game/tutorial_steps.gd` を入れ、そのテスト（test/cr/test_cr_1011.gd など）の期待値が変わるなら「変わる既存のテスト」に書く（SPEC.md の 5 章）。
- 実装役は `OS.`・`Engine.`・`Time.`・`ProjectSettings.`・`FileAccess`・`DirAccess` を新しく使えない（改修 run の禁止 API。今のファイルにある数より増やすと R4・R5 で止まる）。CR の「変えること」にこれらを使う作り方を書かない。今の `scenes/main.gd` の `Time.get_ticks_msec()` は、なぞりを集める 3 か所だけにある。
- 「新しい宣言」の名前は `_` で始めない（改修 run の宣言の検査が数えない）。
- テストでマスのタップを続けるときは、同じマスを 300ms 以内に 2 回タップすると double_tap と読まれる。ヘッドレスのテストではフレームが速く進むので、`await wait_frames(30)` を挟んでも 300ms を超えるとは限らない。続けて 1 回ずつのタップを確かめるときは、違うマスをタップする。
- アプリの起動のシーンは `scenes/app.tscn`（`scenes/app.gd` を付けただけ）。`app.gd` は最初に起動画面 `scenes/title_screen.gd` を出し、ボタンで `start_game(with_tutorial)` が呼ばれて main.tscn を立ち上げ、`main.start_with_tutorial` に選んだ値を入れる。テストと撮影は main.tscn をそのまま立ち上げるので、起動画面もチュートリアルも出ない。
