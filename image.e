class IMAGE
creation make
feature
    make is
    do
    end

    new_dummy is
    require
	not is_connected
    do
	ptr := ext_new_dummy
	if ptr.is_not_null then
	    is_connected := True
	end
    end

    width : INTEGER is
    require
	is_connected
    do
	Result := get_img_width(ptr)
    end

    height : INTEGER is
    require
	is_connected
    do
	Result := get_img_height(ptr)
    end

    is_connected : BOOLEAN

    load(filename : STRING) is
    do
	ptr := load_image(filename.to_external)
	if ptr.is_not_null then
	    is_connected := True
	end
    end

    free is
    require
	is_connected
    do
	if ptr.is_not_null then
	    ptr := free_img(ptr)
	    is_connected := False
	end
    end

    partial_blit(rx, ry, rw, rh, x, y : INTEGER) is
    require
	is_connected
    do
	partial_blit_img(ptr, rx, ry, rw, rh, x, y)
    end

    blit(x, y : INTEGER) is
    require
	is_connected
    do
	blit_img(ptr, x, y)
    end

    render_string(s : STRING; font : TTF_FONT; c : COLOR) is
    require
	not is_connected --otherwise it's a memory leak
	font.is_connected
	s /= Void
	s.count > 0
    do
	ptr := ext_render_text(s.to_external, font.to_external, c.to_external)
	if ptr.is_not_null then
	    is_connected := True
	    convert_display_format
	else
	    io.put_string("render_string " + s.count.to_string + " failed!%N")
	end
    ensure
	is_connected
    end

    set_alpha(a : INTEGER) is
    require
	is_connected
    do
	img_set_alpha(ptr, a)
    end

    convert_display_format_alpha is
    require
	is_connected
    do
	ptr := ext_display_format_alpha(ptr)
    end

    convert_display_format is
    require
	is_connected
    do
	ptr := ext_display_format(ptr)
    end

feature {NONE}
    ptr : POINTER

    load_image(filename : POINTER) : POINTER is
    external "C"
    end

    free_img(i : POINTER) : POINTER is
    external "C"
    end

    ext_render_text(string : POINTER; font : POINTER; c : POINTER) : POINTER is
    external "C"
    end

    get_img_width(i : POINTER) : INTEGER is
    external "C"
    end

    get_img_height(i : POINTER) : INTEGER is
    external "C"
    end

    img_set_alpha(i : POINTER; a : INTEGER) is
    external "C"
    end

    partial_blit_img(i : POINTER; rx, ry, rw, rh, x, y : INTEGER) is
    external "C"
    end

    blit_img(i : POINTER; x, y : INTEGER) is
    external "C"
    end

    ext_display_format_alpha(p : POINTER) : POINTER is
    external "C"
    end

    ext_display_format(p : POINTER) : POINTER is
    external "C"
    end

    ext_new_dummy : POINTER is
    external "C"
    end
end
