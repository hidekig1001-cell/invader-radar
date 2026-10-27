# 10/27: 立ち上げの最初の _refresh で音と振動を出さない直しの当て試し。main 9193cdf（または 1188 の入った main）の写しの根で流す。
#   python3 try_quiet_first_refresh_patch.py
P = "scenes/main.gd"
OLD = "\tvar sfx_name = Sound.sfx_for(last_snapshot, curr_snapshot, last_conflicts, curr_conflicts)\n"
NEW = (OLD +
       "\t# 最初の _refresh（立ち上げ・進み具合の読み直し）では効果音も振動も出さない\n"
       "\tif last_snapshot.is_empty():\n"
       "\t\tsfx_name = \"\"\n")
s = open(P, encoding="utf-8").read()
assert s.count(OLD) == 1, s.count(OLD)
s = s.replace(OLD, NEW)
open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ok:", P)
