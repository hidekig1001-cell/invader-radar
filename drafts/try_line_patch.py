# 10/27: 手触りの 2 本目「そろったら line の音と光」の当て試しの直し。作業の写しの中で流す。
# 3 本の CR に分けてある: rules（core/rules.gd に Rules.filled_lines）→ sound（line の音）→ flash（そろった組を光らせる）。
#   python3 try_line_patch.py          … 3 本とも当てる
#   python3 try_line_patch.py rules    … rules だけ（sound・flash は、それぞれその前までを当てる）
# 前提の改修（1179・1180〜1182）が写しに無ければ、同じフォルダの try_1181_patch.py・try_1182_patch.py を先に当てる
# （try_1181 は 1180 を、try_1182 は 1179 を、無ければ先に当てる）。
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


def has(P, text):
    return text in open(P, encoding="utf-8").read()


def run(name):
    p = os.path.join(HERE, name)
    exec(open(p, encoding="utf-8").read(), {"__file__": p})


def prerequisites():
    if not has("scenes/main.gd", 'sfx_name == "wrong"'):
        run("try_1181_patch.py")
    if not has("scenes/main.gd", "sound.vibrate(250, 0.3)\n") or not has("scenes/main.gd", "var last_dead"):
        run("try_1182_patch.py")


def rules():
    edit("core/rules.gd", [
        ('static func dead_marks(board_state, level) -> Array:',
         '''# 宇宙人 1 つと × だけで埋まりきった（空のマスが無い）行・列・区域。小惑星とレーダーのマスは数えない。
# 宇宙人が赤い（conflicts に入る）組は入れない。並びは行（上から）→ 列（左から）→ 区域（番号の小さい順）。
static func filled_lines(board_state, level) -> Array:
	if board_state == null or level == null:
		return []
	var red = conflicts(board_state, level)
	var groups = []
	for y in range(level.height):
		var cells = []
		for x in range(level.width):
			cells.append(Vector2i(x, y))
		groups.append({"kind": "row", "index": y, "cells": cells})
	for x in range(level.width):
		var cells = []
		for y in range(level.height):
			cells.append(Vector2i(x, y))
		groups.append({"kind": "column", "index": x, "cells": cells})
	for r_id in range(level.region_count()):
		var cells = []
		for y in range(level.height):
			for x in range(level.width):
				if level.region_at(x, y) == r_id:
					cells.append(Vector2i(x, y))
		groups.append({"kind": "region", "index": r_id, "cells": cells})

	var result = []
	for g in groups:
		var kept = []
		var piece_count = 0
		var filled = true
		for c in g["cells"]:
			var skip = false
			for a in level.asteroids:
				if a.x == c.x and a.y == c.y:
					skip = true
			for r in level.radar:
				if r[0] == c.x and r[1] == c.y:
					skip = true
			if skip:
				continue
			kept.append(c)
			var state = board_state.state_at(c.x, c.y)
			if state == 2:
				piece_count += 1
				if red.has(c):
					filled = false
			elif state != 1:
				filled = false
		if filled and piece_count == 1:
			result.append({"kind": g["kind"], "index": g["index"], "cells": kept})
	return result


static func dead_marks(board_state, level) -> Array:'''),
    ])


def sound():
    edit("scenes/sound.gd", [
        ('const SFX_DEAD := preload("res://assets/audio/dead.wav")\n',
         'const SFX_DEAD := preload("res://assets/audio/dead.wav")\nconst SFX_LINE := preload("res://assets/audio/line.wav")\n'),
        ('\t\t"dead":\n\t\t\tstream = SFX_DEAD\n',
         '\t\t"dead":\n\t\t\tstream = SFX_DEAD\n\t\t"line":\n\t\t\tstream = SFX_LINE\n'),
    ])
    edit("scenes/main.gd", [
        ('var last_dead: bool = false\n', 'var last_dead: bool = false\nvar last_lines: Array = []\n'),
        ('\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n',
         '\t# そろった組（Rules.filled_lines）が新しくできた手は、clear・place・mark の代わりに line を鳴らす（チュートリアルと最初の _refresh は除く）\n'
         '\tvar curr_lines: Array = []\n'
         '\tif not is_tutorial():\n'
         '\t\tcurr_lines = Rules.filled_lines(session.board, session.level)\n'
         '\tvar new_lines: Array = []\n'
         '\tfor g in curr_lines:\n'
         '\t\tif not last_lines.has(g):\n'
         '\t\t\tnew_lines.append(g)\n'
         '\tif sfx_name in ["clear", "place", "mark"] and not last_snapshot.is_empty() and not new_lines.is_empty():\n'
         '\t\tsfx_name = "line"\n'
         '\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n'),
        ('\tlast_dead = curr_dead\n', '\tlast_dead = curr_dead\n\tlast_lines = curr_lines\n'),
    ])


def flash():
    edit("scenes/board_view.gd", [
        ('var pop_clock: float = 0.0\n',
         'var pop_clock: float = 0.0\nconst LINE_FLASH_TIME := 0.3\nvar flashes: Array = []\nvar flash_cells: Array = []\nvar flash_start: float = -1.0\n'),
        ('\t# 5. Draw Highlight/Darkening (CR-1022)\n',
         '\t# そろった組を短く光らせる（明るさは flash_alpha）\n'
         '\tvar flash_a := flash_alpha(pop_clock)\n'
         '\tif flash_a > 0.0:\n'
         '\t\tfor c in flash_cells:\n'
         '\t\t\t_draw_round_rect(tile_rect(c.x, c.y), radius, Color(1, 1, 1, flash_a), true)\n\n'
         '\t# 5. Draw Highlight/Darkening (CR-1022)\n'),
        ('func _process(delta: float) -> void:\n\tpop_clock += delta\n\tvar needs_redraw := false\n',
         'func flash_lines(lines: Array) -> void:\n'
         '\tflash_cells = []\n'
         '\tfor line in lines:\n'
         '\t\tflashes.append(line["cells"])\n'
         '\t\tfor c in line["cells"]:\n'
         '\t\t\tif not flash_cells.has(c):\n'
         '\t\t\t\tflash_cells.append(c)\n'
         '\tflash_start = pop_clock\n'
         '\tqueue_redraw()\n\n\n'
         'func flash_alpha(now: float) -> float:\n'
         '\tif flash_start < 0.0:\n'
         '\t\treturn 0.0\n'
         '\tvar t := (now - flash_start) / LINE_FLASH_TIME\n'
         '\tif t < 0.0 or t >= 1.0:\n'
         '\t\treturn 0.0\n'
         '\treturn 0.5 * (1.0 - t)\n\n\n'
         'func _process(delta: float) -> void:\n\tpop_clock += delta\n\tvar needs_redraw := false\n'
         '\tif flash_start >= 0.0 and pop_clock - flash_start < LINE_FLASH_TIME + delta:\n'
         '\t\tneeds_redraw = true\n'),
    ])
    edit("scenes/main.gd", [
        ('\t\tsound.play_sfx(sfx_name)\n',
         '\t\tsound.play_sfx(sfx_name)\n\t\tif sfx_name == "line":\n\t\t\tboard_view.flash_lines(new_lines)\n'),
    ])


stop = sys.argv[1] if len(sys.argv) > 1 else "flash"
prerequisites()
rules()
if stop in ("sound", "flash"):
    sound()
if stop == "flash":
    flash()
