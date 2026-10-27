# 10/27: 数字付きの岩をタップ・ダブルタップしたら NG の音と振動を 1 回出す直しの当て試し。main 8111de3 の写しの根で流す。
#   python3 try_rock_ng_both_patch.py   … 数字付きの岩と数字の無い岩（小惑星）の両方
import sys

BOTH = True  # 数字付きの岩と数字の無い岩（小惑星）の両方（ユーザーの判断 D-20261027-2103＝A）
P = "scenes/main.gd"
cond = "session.is_radar(x, y) or session.is_asteroid(x, y)" if BOTH else "session.is_radar(x, y)"
s = open(P, encoding="utf-8").read()
old_tap = "\t\t\telse:\n\t\t\t\tsession.tap(c.x, c.y)\n"
assert s.count(old_tap) == 1
s = s.replace(old_tap, "\t\t\telse:\n\t\t\t\trock_ng(c.x, c.y)\n\t\t\t\tsession.tap(c.x, c.y)\n")
anchor = "func tutorial_accepts_cell(cell: Vector2i) -> bool:\n"
assert s.count(anchor) == 1
s = s.replace(anchor,
    "# 岩のマスをタップしたら、NG の音（wrong）と振動を 1 回出す。盤・手数・元に戻すの記録は変えない。\n"
    "# ダブルタップは 1 回目のタップで鳴っているので、ここは画面のタップからだけ呼ぶ。\n"
    "func rock_ng(x: int, y: int) -> bool:\n"
    "\tif is_tutorial() or session == null:\n"
    "\t\treturn false\n"
    "\tif not (" + cond + "):\n"
    "\t\treturn false\n"
    "\tsound.play_sfx(\"wrong\")\n"
    "\tsound.vibrate(250, 0.3)\n"
    "\treturn true\n\n" + anchor)
open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ok:", P, "both" if BOTH else "radar only")
