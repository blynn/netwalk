class LISTBOX
inherit
    WIDGET
creation make
feature
    string_list : LINKED_LIST[STRING]
    string : STRING
    list_i : INTEGER

    put_list(l : like string_list) is
    do
	string_list := l
    end

    put_string(s : STRING) is
    require
	string_list.has(s)
    do
	list_i := string_list.index_of(s)
	!!string.copy(s)
	update_image
    end

    prev_string is
    local
	i : INTEGER
    do
	i := list_i - 1
	if i < string_list.lower then
	    i := string_list.upper
	end
	if i /= list_i then
	    list_i := i
	    put_string(string_list @ list_i)
	    raise_signal(signal_change)
	    update_image
	end
    end

    next_string is
    local
	i : INTEGER
    do
	i := list_i + 1
	if i > string_list.upper then
	    i := string_list.lower
	end
	if i /= list_i then
	    list_i := i
	    put_string(string_list @ list_i)
	    raise_signal(signal_change)
	    update_image
	end
    end

    make is
    do
	widget_init
	!!string.make(128)
	!!string_list.make
	!!textimg.make
	textimg.new_dummy
    end

    process_event(e : EVENT) is
    do
	if e.type = sdl_mousebuttondown then
	    if e.i1 = 1 then
		next_string
	    else
		prev_string
	    end
	end
    end

    update is
    do
	if has_focus then
	    fill_rect(0, 0, width, height, white)
	else
	    fill_rect(0, 0, width, height, grey)
	end
	fill_rect(1, 1, width - 2, height - 2, black)
	if string.count > 0 then
	    blit(textimg, 2, 2)
	end
    end

    textimg : IMAGE

    update_image is
    do
	textimg.free
	if string.count > 0 then
	    textimg.render_string(string, font, white)
	end
    end
end
