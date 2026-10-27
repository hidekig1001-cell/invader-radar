# 10/27: 使われない last_dead を消し、test_cr_1187 の CHECK 3 の迷いのコメントを消す片づけの当て試し。main の作業の写しの根で流す。
#   python3 try_cleanup_last_dead_patch.py
# 振る舞いは変えない（last_dead はどこからも読まれていない。テストは表明を変えない）。


def edit(path, pairs):
    s = open(path, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (path, old, s.count(old))
        s = s.replace(old, new)
    open(path, "w", encoding="utf-8", newline="\n").write(s)


edit("scenes/main.gd", [
    ("var last_dead: bool = false\n", ""),
    ("\tlast_dead = not curr_dead_marks.is_empty()\n", ""),
    ("\tlast_dead = false\n", ""),
    ("\tlast_dead = not marks.is_empty()\n", ""),
])
edit("test/cr/test_cr_1187.gd", [
    ('\tassert_eq(m.sound.played[-1], "line") # Or whatever sfx corresponds to clearing the dead state / placing alien. The prompt says "line" for this step in test 3 description? \n',
     '\tassert_eq(m.sound.played[-1], "line")\n'),
    ('\t# Wait, prompt says: "m.session.double_tap(1, 1) をしたあと... m.sound.played[-1] は \\"line\\""\n', ''),
    ('\tassert_eq(m.sound.vibrations, [15, 15, 15, 250]) # No new vibration for line? Or maybe line has no vibration in this context? \n',
     '\tassert_eq(m.sound.vibrations, [15, 15, 15, 250])\n'),
    ('\t# Actually, looking at CR-1187 description: "sfx_name が \\"mark\\" か \\"clear\\" で... sfx_name を \\"dead\\" にする".\n', ''),
    ("\t# If we place an alien, it's a \"place\" or \"line\" event. It removes the dead state.\n", ''),
    ('\t# The prompt explicitly says: m.sound.played[-1] は "line", m.sound.vibrations は [15, 15, 15, 250].\n', ''),
    ("\t# This implies the double_tap triggered a \"line\" sound (maybe because it completed a line? No, region 0 is not a line. \n", ''),
    ("\t# Ah, `Rules.filled_lines` might consider the row/col if they are full? \n", ''),
    ("\t# Let's trust the prompt's expected values.\n", ''),
])
print("ok")
