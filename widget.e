deferred class WIDGET
inherit
    SDL_CONSTANT;
    COLOR_TABLE;
    CONFIG
feature
    has_focus : BOOLEAN

    put_focus(b : BOOLEAN) is
    do
	has_focus := b
    end

    font : TTF_FONT is
    do
	Result := config.mainfont
    end

    widget_init is
    do
	!!signal_table.make
    end

    free is
    do
    end

    signal_activate : INTEGER is 1
    signal_cancel : INTEGER is 2
    signal_change : INTEGER is 3

    signal_table : DICTIONARY[COMMAND, INTEGER]

    put_command(c : COMMAND; i : INTEGER) is
    do
	signal_table.put(c, i)
    end

    raise_signal(i : INTEGER) is
    do
	if signal_table.has(i) then
	    signal_table.at(i).execute
	end
    end

    offsetx : INTEGER
    offsety : INTEGER
    width : INTEGER
    height : INTEGER

    put_xy(x, y : INTEGER) is
    do
	offsetx := x
	offsety := y
    end

    put_size(w, h : INTEGER) is
    do
	width := w
	height := h
    end

    contains(x, y : INTEGER) : BOOLEAN is
    do
	Result := x >= offsetx and then x < offsetx + width
		and then y >= offsety and then y < offsety + height
    end

    handle_event(e : EVENT) is
    do
	e.put_x(e.x - offsetx)
	e.put_y(e.y - offsety)
	process_event(e)
    end

    process_event(e : EVENT) is
    deferred
    end

    update is
    deferred
    end

    blank is
    do
	fill_rect(0, 0, width, height, black)
    end

    fill_rect(x, y, w, h : INTEGER; c : COLOR) is
    do
	ext_fill_rect(x + offsetx, y + offsety, w, h, c.to_integer)
    end

    ext_fill_rect(x, y, w, h, c : INTEGER) is
    external "C"
    end

    blit(img : IMAGE; x, y : INTEGER) is
    do
	img.blit(x + offsetx, y + offsety)
    end

    ext_blit_surface(p : POINTER; x, y : INTEGER) is
    external "C"
    end

    ext_get_mouse_state is
    external "C"
    end

    last_mouse_x : INTEGER is
    do
	Result := get_last_mouse_x - offsetx
    end

    last_mouse_y : INTEGER is
    do
	Result := get_last_mouse_y - offsety
    end

    get_last_mouse_x : INTEGER is
    external "C"
    end

    get_last_mouse_y : INTEGER is
    external "C"
    end

    text_width : INTEGER
    text_height : INTEGER
    measure_text_size(s : STRING) is
    do
	ext_get_text_size(font.to_external, s.to_external)
	text_width := ext_get_tsw
	text_height := ext_get_tsh
    end

    ext_get_text_size(f : POINTER; s : POINTER) is
    external "C"
    end

    ext_get_tsw : INTEGER is
    external "C"
    end

    ext_get_tsh : INTEGER is
    external "C"
    end
end
