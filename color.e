class COLOR
creation make
feature
    make(r, g, b : INTEGER) is
    do
	pointer := ext_make_color(r, g, b)
	to_integer := ext_convert_color(r, g, b)
	to_gfx_integer := r * 256 * 256 * 256 + g * 256 * 256 + b * 256 + 255
    end

    free is
    do
	ext_free_color(pointer)
    end

    to_external : POINTER is
    do
	Result := pointer
    end

    to_integer : INTEGER

    to_gfx_integer : INTEGER

    pointer : POINTER

    ext_make_color(r, g, b : INTEGER) : POINTER is
    external "C"
    end

    ext_free_color(p : POINTER) is
    external "C" alias "free"
    end

    ext_convert_color(r, g, b : INTEGER) : INTEGER is
    external "C"
    end
end
