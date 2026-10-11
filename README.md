# Invader Radar（土台 base-v1）

縦画面（1080x1920）の 4x4 の論理パズルの共通の土台。Godot 4.7、GDScript、GUT。
色の区域に分かれた盤にインベーダー（今は仮の四角）を置く。決まりは今は「駒が target 個」だけで、本物の決まりは CR で足す。

## 遊び方（今の版）
- 1 回タップ: × の印。もう一度で消す。
- ダブルタップ: 駒を置く（もう一度で取り除く）。
- スワイプ: なぞったマスに ×。
- 上に 面・スコア・ヒントの残り。UNDO で 1 つ戻す。HINT は残りが減るだけ（中身はまだ）。

## 作り方・試験
```
source ~/AI/godot/env.sh        # GODOT_BIN などを読み込む
tools/run_tests.sh              # 読み込み・スモーク（600 フレーム）・GUT
```
撮影（改修 run 用）: `godot --path . -s res://.autedev/shot.gd -- --out=/tmp/a.png --frames=60 --scenario=idle|play`（`DISPLAY=:99`）。
APK: `godot --headless --path . --export-debug Android <出力先.apk>`（出力先は export_presets.cfg）。

## フォルダ
`core/`（規則）・`game/`（面と操作）・`scenes/`（画面）・`data/levels/`（面の JSON）・`test/unit/`・`tools/`・`.autedev/`。
層の分け方、決まりの置き場所、CR を書くときの注意は `SPEC.md`。
