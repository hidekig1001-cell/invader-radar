# 10/27: 「盤が大きくなる面のお知らせ」を派手にする案 A（金色のタイルが弾んで出る＋音と振動）の当て試しの直し。
# main 0ae3435（v1.94-cr1185）の写しの中で流す。
def edit(P, pairs):
    s = open(P, encoding="utf-8").read()
    for old, new in pairs:
        assert s.count(old) == 1, (P, old)
        s = s.replace(old, new)
    open(P, "w", encoding="utf-8", newline="\n").write(s)


edit("scenes/message_bubble.gd", [
    ('const PANEL_MIN_FONT_SIZE := 20\n',
     'const PANEL_MIN_FONT_SIZE := 20\n'
     'const SIZE_UP_BG := Color8(255, 215, 64)\n'
     'const SIZE_UP_BORDER := Color8(230, 110, 20)\n'
     'const SIZE_UP_POP_TIME := 0.3\n'),
    ('var normal_box: StyleBox = null\n',
     'var normal_box: StyleBox = null\n'
     'var size_up_mode: bool = false\n'
     'var pop_age: float = -1.0\n'),
    # clear_text: 金色のタイルの記録・大きさ・字の大きさを戻す
    ('\tif tile_mode:\n\t\ttile_mode = false\n',
     '\tif size_up_mode:\n'
     '\t\tsize_up_mode = false\n'
     '\t\tpop_age = -1.0\n'
     '\t\tscale = Vector2.ONE\n'
     '\t\tadd_theme_font_size_override("font_size", FONT_SIZE)\n'
     '\tif tile_mode:\n\t\ttile_mode = false\n'),
    ('func show_panel(text_to_show: String) -> void:',
     '# 盤が大きくなる面のお知らせ。タイルの形で出し、金色の地・太い橙の縁・大きな字にして、0.3 秒弾ませる。\n'
     'func show_size_up(text_to_show: String, center: Vector2) -> void:\n'
     '\tshow_tile(text_to_show, center)\n'
     '\tsize_up_mode = true\n'
     '\tadd_theme_stylebox_override("normal", size_up_box())\n'
     '\tadd_theme_font_size_override("font_size", fit_font_size(text_to_show, TILE_SIZE, 52, 36))\n'
     '\tpivot_offset = TILE_SIZE / 2.0\n'
     '\tpop_age = 0.0\n'
     '\tscale = Vector2.ONE\n'
     '\n\n'
     'func size_up_box() -> StyleBoxFlat:\n'
     '\tvar box := StyleBoxFlat.new()\n'
     '\tbox.bg_color = SIZE_UP_BG\n'
     '\tbox.border_color = SIZE_UP_BORDER\n'
     '\tbox.set_border_width_all(8)\n'
     '\tbox.set_corner_radius_all(24)\n'
     '\tbox.anti_aliasing = true\n'
     '\treturn box\n'
     '\n\n'
     'static func size_up_pop_scale(age: float) -> float:\n'
     '\tif age < 0.0 or age >= SIZE_UP_POP_TIME:\n'
     '\t\treturn 1.0\n'
     '\treturn 1.0 + 0.25 * sin(PI * age / SIZE_UP_POP_TIME)\n'
     '\n\n'
     'func step_pop(delta: float) -> void:\n'
     '\tif pop_age < 0.0:\n'
     '\t\treturn\n'
     '\tpop_age += delta\n'
     '\tif pop_age >= SIZE_UP_POP_TIME:\n'
     '\t\tpop_age = -1.0\n'
     '\t\tscale = Vector2.ONE\n'
     '\telse:\n'
     '\t\tvar s := size_up_pop_scale(pop_age)\n'
     '\t\tscale = Vector2(s, s)\n'
     '\n\n'
     'func show_panel(text_to_show: String) -> void:'),
    ('func _process(delta: float) -> void:\n\tstep_blink(delta)\n',
     'func _process(delta: float) -> void:\n\tstep_blink(delta)\n\tstep_pop(delta)\n'),
])
edit("scenes/main.gd", [
    ('\t\t\tbubble.show_tile(size_up_tile_text(), board_view.position + board_view.board_rect().get_center())\n',
     '\t\t\tbubble.show_size_up(size_up_tile_text(), board_view.position + board_view.board_rect().get_center())\n'
     '\t\t\tsound.play_sfx("line")\n'
     '\t\t\tsound.vibrate(60, 0.6)\n'),
])
