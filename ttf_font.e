class TTF_FONT
creation make, load
feature
    is_connected : BOOLEAN

    make is
    do
    end

    load(filename : STRING; size : INTEGER) is
    require
	filename /= Void
    do
	ptr := ext_ttf_openfont(filename.to_external, size)
	if ptr.is_not_null then
	    is_connected := True
	else
	     io.put_string("Failed to load font: " + filename + "%N")
	end
    end

    free is
    do
	if ptr.is_not_null then
	    ptr := free_ttf_font(ptr)
	    is_connected := False
	end
    end

    set_style(i : INTEGER) is
    do
	ttf_setfontstyle(ptr, i)
    end

    to_external : POINTER is
    do
	Result := ptr
    end

    ttf_setfontstyle(p : POINTER; i : INTEGER) is
    external "C" alias "TTF_SetFontStyle"
    end

    free_ttf_font(font : POINTER) : POINTER is
    external "C"
    end

feature {NONE}
    ptr : POINTER

    ext_ttf_openfont(p : POINTER; size : INTEGER) : POINTER is
    external "C"
    end
end
