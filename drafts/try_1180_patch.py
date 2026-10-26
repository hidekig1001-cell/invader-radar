# 10/26: CR-1180 の当て試しの直し（× を付けた手で 15 ミリ秒・振幅 0.4 の小さく短い振動。sound.vibrate に振幅を足す）。作業の写しの中で流す。
# 土台は main e6cf4ca（CR-1177 の vibrate(ms) が入った版）。CR-1179 が入った main でも当たる。
def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


edit("scenes/sound.gd", [
    ('var vibrations: Array = []\n', 'var vibrations: Array = []\nvar vibration_amplitudes: Array = []\n'),
    ('func vibrate(ms: int) -> void:\n\tvibrations.append(ms)\n\tInput.vibrate_handheld(ms)\n',
     '# amplitude は 0〜1 の強さ。-1.0 は端末の決まりの強さ（Input.vibrate_handheld の既定）。\n'
     'func vibrate(ms: int, amplitude: float = -1.0) -> void:\n\tvibrations.append(ms)\n\tvibration_amplitudes.append(amplitude)\n\tInput.vibrate_handheld(ms, amplitude)\n'),
])
edit("scenes/main.gd", [
    ('\t\tsound.play_sfx(sfx_name)\n',
     '\t\tsound.play_sfx(sfx_name)\n\t\tif sfx_name == "mark":\n\t\t\tsound.vibrate(15, 0.4)\n'),
])
