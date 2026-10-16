#!/usr/bin/env bash
# 使い方: tools/run_tests.sh
#   環境変数 GODOT_BIN（Godot 4.7.x の実行ファイル）が必要。なければ PATH の godot を使う。
#   GUT_DIRS=<res:// のフォルダをカンマ区切り> で、3) で走らせるテストのフォルダを差し替えられる（未設定なら test/unit と test/integration）。
#   Godot の周辺環境（HOME の差し替えなど）を読み込みたいときは GODOT_ENV=<source するファイル> を渡す。
#   1) プロジェクトがエラーなく読み込めるか（tools/smoke.gd で最初のシーンを 3 フレーム動かす）
#   2) 本物のタイマーで 600 フレーム（10 ゲーム秒）動かす煙テスト（tools/smoke.gd。終わる前に音を止めて実時間 150ms 待つ。Godot 4.7.2 は鳴らしたまま終わると "resources still in use at exit" を出すため）
#   3) モバイル規則の単体テスト＋シーンの結合テスト（GUT、ヘッドレス）
# 画面は開かない。ネットワークは使わない。終了コードは失敗した段階の数。
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -n "${GODOT_ENV:-}" ]; then
  # shellcheck disable=SC1090
  source "$GODOT_ENV"
fi
GODOT_BIN="${GODOT_BIN:-$(command -v godot || true)}"
if [ -z "$GODOT_BIN" ] || [ ! -x "$GODOT_BIN" ]; then
  echo "GODOT_BIN is not set (or not executable). Set GODOT_BIN=/path/to/Godot_v4.7.x or put godot on PATH." >&2
  exit 99
fi
fail=0
mkdir -p "$ROOT/.test_tmp"

echo "== 1) load check"
[ -d "$ROOT/.godot" ] || "$GODOT_BIN" --headless --path "$ROOT" --import > "$ROOT/.test_tmp/import.log" 2>&1
"$GODOT_BIN" --headless --path "$ROOT" --fixed-fps 60 -s tools/smoke.gd -- --frames=3 --scene=res://scenes/app.tscn > "$ROOT/.test_tmp/quit.log" 2>&1
if grep -qE 'ERROR|SCRIPT ERROR|Parse Error|Failed' "$ROOT/.test_tmp/quit.log"; then
  grep -E -A2 'ERROR|Parse Error|Failed' "$ROOT/.test_tmp/quit.log" | head -20; fail=$((fail+1))
else echo "OK"; fi

echo "== 2) smoke run (main scene with real timers, 10 game-seconds, 600 frames at fixed 60 fps)"
timeout 120 "$GODOT_BIN" --headless --path "$ROOT" --fixed-fps 60 -s tools/smoke.gd -- --frames=600 --scene=res://scenes/app.tscn > "$ROOT/.test_tmp/smoke.log" 2>&1
if grep -qE 'ERROR|Parse Error|Failed' "$ROOT/.test_tmp/smoke.log"; then
  grep -E -A2 'ERROR|Parse Error|Failed' "$ROOT/.test_tmp/smoke.log" | head -20; fail=$((fail+1))
else echo "OK"; fi

echo "== 3) GUT (unit + integration)"
"$GODOT_BIN" --headless --path "$ROOT" -s addons/gut/gut_cmdln.gd \
  -gdir="${GUT_DIRS:-res://test/unit,res://test/integration}" -gprefix=test_ -gexit -gdisable_colors \
  -gjunit_xml_file=res://.test_tmp/gut.xml > "$ROOT/.test_tmp/gut.log" 2>&1
rc=$?
grep -E '^(Tests|Passing|Failing|Pending|Asserts)|\[Failed\]|SCRIPT ERROR|---- All tests passed' "$ROOT/.test_tmp/gut.log" | head -40
[ $rc -eq 0 ] || fail=$((fail+1))

echo "== failed stages: $fail"
exit $fail
