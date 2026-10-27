# 10/27: Rules.dead_marks の判定の順を filled_lines に合わせる直しの当て試し。main の作業の写しの根で流す。
#   python3 try_dead_marks_order_patch.py
# 行・列・区域の 3 か所で、小惑星・レーダーのマスの判定を、マスの状態の判定より前に移す（岩のマスの宇宙人を「宇宙人がいる」と数えない）。
P = "core/rules.gd"


def edit(path, pairs):
    s = open(path, encoding="utf-8").read()
    for old, new, count in pairs:
        assert s.count(old) == count, (path, old, s.count(old))
        s = s.replace(old, new)
    open(path, "w", encoding="utf-8", newline="\n").write(s)


def block(tabs):
    t = "\t" * tabs
    old = (t + "var state = board_state.state_at(x, y)\n"
           + t + "if state == 2: # Alien/Piece\n"
           + t + "\thas_alien = true\n"
           + t + "\tbreak\n"
           + t + "elif is_asteroid.call(x, y) or is_radar_cell.call(x, y):\n"
           + t + "\tcontinue\n"
           + t + "elif state == 1: # Mark\n")
    new = (t + "if is_asteroid.call(x, y) or is_radar_cell.call(x, y):\n"
           + t + "\tcontinue\n"
           + t + "var state = board_state.state_at(x, y)\n"
           + t + "if state == 2: # Alien/Piece\n"
           + t + "\thas_alien = true\n"
           + t + "\tbreak\n"
           + t + "elif state == 1: # Mark\n")
    return old, new


o3, n3 = block(3)
o4, n4 = block(4)
edit(P, [(o3, n3, 2), (o4, n4, 1)])
print("ok:", P)
