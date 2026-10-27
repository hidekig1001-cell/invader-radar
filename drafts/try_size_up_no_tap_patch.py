# 10/27: 盤が大きくなる面のお知らせから「タップではじめる」（英語は「TAP TO START」）を消す直しの当て試し。main 8111de3 の写しの根で流す。
P = "scenes/main.gd"
pairs = [
    ('"この面からはマスが %d×%d になるよ。\\nがんばって！  タップではじめる" % [w, w]', '"この面からはマスが %d×%d になるよ。\\nがんばって！" % [w, w]'),
    ('"THE BOARD IS %dx%d FROM HERE.\\nGOOD LUCK!  TAP TO START" % [w, w]', '"THE BOARD IS %dx%d FROM HERE.\\nGOOD LUCK!" % [w, w]'),
]
s = open(P, encoding="utf-8").read()
for a, b in pairs:
    assert s.count(a) == 1, a
    s = s.replace(a, b)
open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ok:", P)
