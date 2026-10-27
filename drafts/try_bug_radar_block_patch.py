# 10/27: 数字付きの岩（レーダー）に × も宇宙人も付けられないようにする直しの当て試し。main 0ae3435 の作業の写しの根で流す。
#   python3 try_bug_radar_block_patch.py
# 直しは game/session.gd だけ（is_radar を足し、tap・double_tap・swipe で弾く）。
import sys

P = "game/session.gd"


def edit(path, pairs):
    s = open(path, encoding="utf-8").read()
    for old, new, count in pairs:
        assert s.count(old) == count, (path, old, s.count(old))
        s = s.replace(old, new)
    open(path, "w", encoding="utf-8", newline="\n").write(s)


edit(P, [
    # tap と double_tap の最初の判定（2 か所）
    ("\tif is_asteroid(x, y) or is_given(x, y):\n\t\treturn false\n",
     "\tif is_asteroid(x, y) or is_radar(x, y) or is_given(x, y):\n\t\treturn false\n", 2),
    # swipe で除くマス
    ("\t\tif not is_asteroid(c.x, c.y) and not is_given(c.x, c.y):\n",
     "\t\tif not is_asteroid(c.x, c.y) and not is_radar(c.x, c.y) and not is_given(c.x, c.y):\n", 1),
    # is_radar を is_given の前に足す
    ("func is_given(x: int, y: int) -> bool:\n",
     "# 数字付きの岩（レーダー）のマスかどうか。× も宇宙人も付けられない。\n"
     "func is_radar(x: int, y: int) -> bool:\n"
     "\tif level == null:\n"
     "\t\treturn false\n"
     "\tfor r in level.radar:\n"
     "\t\tif r[0] == x and r[1] == y:\n"
     "\t\t\treturn true\n"
     "\treturn false\n\n\n"
     "func is_given(x: int, y: int) -> bool:\n", 1),
])
print("ok:", P)
