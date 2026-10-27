# 10/27: × だけの組が新しくできるたびに dead を鳴らす直しの当て試し。main 0ae3435 の作業の写しの根で流す。
#   python3 try_bug_dead_new_group_patch.py
# 直しは scenes/main.gd だけ（last_dead を last_dead_marks に替え、新しく × だけの組に入った × があれば mark・clear の手を dead に替える）。

P = "scenes/main.gd"


def edit(path, pairs):
    s = open(path, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (path, old, s.count(old))
        s = s.replace(old, new)
    open(path, "w", encoding="utf-8", newline="\n").write(s)


edit(P, [
    ("var last_dead: bool = false\n", "var last_dead_marks: Array = []\n"),
    ("\tvar curr_dead := false\n"
     "\tif not is_tutorial():\n"
     "\t\tcurr_dead = not Rules.dead_marks(session.board, session.level).is_empty()\n"
     "\t\tif sfx_name == \"mark\" and not last_snapshot.is_empty() and not last_dead and curr_dead:\n"
     "\t\t\tsfx_name = \"dead\"\n",
     "\t# 前の手のあとには × だけの組に入っていなかった × が組に入った手（新しい × だけの組ができた手）は dead を鳴らす\n"
     "\tvar curr_dead_marks: Array = []\n"
     "\tif not is_tutorial():\n"
     "\t\tcurr_dead_marks = Rules.dead_marks(session.board, session.level)\n"
     "\tvar new_dead := false\n"
     "\tfor c in curr_dead_marks:\n"
     "\t\tif not last_dead_marks.has(c):\n"
     "\t\t\tnew_dead = true\n"
     "\tif sfx_name in [\"mark\", \"clear\"] and not last_snapshot.is_empty() and new_dead:\n"
     "\t\tsfx_name = \"dead\"\n"),
    ("\tlast_dead = curr_dead\n", "\tlast_dead_marks = curr_dead_marks\n"),
    ("\tlast_dead = false\n", "\tlast_dead_marks = []\n"),
    ("\tlast_dead = not Rules.dead_marks(session.board, session.level).is_empty()\n",
     "\tlast_dead_marks = Rules.dead_marks(session.board, session.level)\n"),
])
print("ok:", P)
