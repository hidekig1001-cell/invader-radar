# 10/26: CR-1179 の当て試しの直し（× だけの組ができた瞬間に dead を鳴らし 120 ミリ秒振動）。作業の写しの中で流す。
# sound.gd に vibrate が無ければ（CR-1177 がまだ入っていなければ）、先に CR-1177 の直しを当てる。
# dead.wav が無ければ、無音の短い wav（44100 Hz・16 bit・2 ch・0.5 秒）を置く。
import os
import wave


def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


# 効果音のファイル（本物は別に用意する。無い間だけ無音で置く）
WAV = os.path.join("assets", "audio", "dead.wav")
if not os.path.exists(WAV):
    w = wave.open(WAV, "wb")
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(44100)
    w.writeframes(b"\x00\x00\x00\x00" * 22050)
    w.close()

# CR-1177（宇宙人を置いたとき 30 ミリ秒振動）が無ければ先に当てる
if "func vibrate(ms: int) -> void:" not in open("scenes/sound.gd", encoding="utf-8").read():
    edit("scenes/sound.gd", [
        ('var played: Array = []\n', 'var played: Array = []\nvar vibrations: Array = []\n'),
        ('func play_music(music: String) -> void:',
         'func vibrate(ms: int) -> void:\n\tvibrations.append(ms)\n\tInput.vibrate_handheld(ms)\n\n\nfunc play_music(music: String) -> void:'),
    ])
    edit("scenes/main.gd", [
        ('\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n',
         '\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n\t\tif sfx_name == "place":\n\t\t\tsound.vibrate(30)\n'),
    ])

# CR-1179
edit("scenes/sound.gd", [
    ('const SFX_BUTTON := preload("res://assets/audio/button.wav")\n',
     'const SFX_BUTTON := preload("res://assets/audio/button.wav")\nconst SFX_DEAD := preload("res://assets/audio/dead.wav")\n'),
    ('\t\t"button":\n\t\t\tstream = SFX_BUTTON\n',
     '\t\t"button":\n\t\t\tstream = SFX_BUTTON\n\t\t"dead":\n\t\t\tstream = SFX_DEAD\n'),
])
edit("scenes/main.gd", [
    ('var last_conflicts: int = 0\n', 'var last_conflicts: int = 0\nvar last_dead: bool = false\n'),
    ('\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n',
     '\t# × だけの組（Rules.dead_marks）が無い→ある に変わった × の手は、mark の代わりに dead を鳴らす（チュートリアルと最初の _refresh は除く）\n'
     '\tvar curr_dead: bool = not is_tutorial() and not Rules.dead_marks(session.board, session.level).is_empty()\n'
     '\tif sfx_name == "mark" and not last_snapshot.is_empty() and not last_dead and curr_dead:\n'
     '\t\tsfx_name = "dead"\n'
     '\tif sfx_name != "":\n\t\tsound.play_sfx(sfx_name)\n\t\tif sfx_name == "dead":\n\t\t\tsound.vibrate(120)\n'),
    ('\tlast_conflicts = curr_conflicts\n', '\tlast_conflicts = curr_conflicts\n\tlast_dead = curr_dead\n'),
])
