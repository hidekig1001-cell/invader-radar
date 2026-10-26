# 10/26: CR-1182 の当て試しの直し（CR-1179 の "dead" の手の振動を 120 ミリ秒から 250 ミリ秒・振幅 0.3 に替える）。作業の写しの中で流す。
# CR-1180（振幅）と CR-1179（dead）が無ければ、先に同じフォルダの try_1180_patch.py と try_1179_patch.py（draft/cr1179 の写し）を当てる。
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


def run(name):
    p = os.path.join(HERE, name)
    exec(open(p, encoding="utf-8").read(), {"__file__": p})


if "amplitude: float" not in open("scenes/sound.gd", encoding="utf-8").read():
    run("try_1180_patch.py")
if "var last_dead" not in open("scenes/main.gd", encoding="utf-8").read():
    run("try_1179_patch.py")

edit("scenes/main.gd", [
    ('sound.vibrate(120)', 'sound.vibrate(250, 0.3)'),
])
