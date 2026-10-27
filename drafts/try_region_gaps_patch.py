# 10/27: 区域の番号を Level.parse で 0 から詰め直す直しの当て試し。main 9193cdf の写しの根で流す。
#   python3 try_region_gaps_patch.py
P = "game/level.gd"
OLD = ("\tfor y in range(h):\n"
       "\t\tif not (rows[y] is Array) or rows[y].size() != w:\n"
       "\t\t\treturn false\n"
       "\t\tfor x in range(w):\n"
       "\t\t\tg.set_cell(x, y, int(rows[y][x]))\n")
NEW = (OLD +
       "\t# 区域の番号を小さい順に 0, 1, 2, … に詰め直す（0 から続いている面では変わらない）\n"
       "\tvar ids: Array = []\n"
       "\tfor y in range(h):\n"
       "\t\tfor x in range(w):\n"
       "\t\t\tvar v: int = g.get_cell(x, y)\n"
       "\t\t\tif not ids.has(v):\n"
       "\t\t\t\tids.append(v)\n"
       "\tids.sort()\n"
       "\tfor y in range(h):\n"
       "\t\tfor x in range(w):\n"
       "\t\t\tg.set_cell(x, y, ids.find(g.get_cell(x, y)))\n")
s = open(P, encoding="utf-8").read()
assert s.count(OLD) == 1, s.count(OLD)
s = s.replace(OLD, NEW)
open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ok:", P)
