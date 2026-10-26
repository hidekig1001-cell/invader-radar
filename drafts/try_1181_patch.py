# 10/26: CR-1181 の当て試しの直し（宇宙人がぶつかった手 "wrong" で 250 ミリ秒・振幅 0.3 の弱め・長めの振動）。作業の写しの中で流す。
# sound.vibrate に振幅が無ければ（CR-1180 がまだ入っていなければ）、先に同じフォルダの try_1180_patch.py を当てる。
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


if "amplitude: float" not in open("scenes/sound.gd", encoding="utf-8").read():
    exec(open(os.path.join(HERE, "try_1180_patch.py"), encoding="utf-8").read(), {"__file__": os.path.join(HERE, "try_1180_patch.py")})

edit("scenes/main.gd", [
    ('\t\tsound.play_sfx(sfx_name)\n',
     '\t\tsound.play_sfx(sfx_name)\n\t\tif sfx_name == "wrong":\n\t\t\tsound.vibrate(250, 0.3)\n'),
])
