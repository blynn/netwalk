class TEXTBOX
inherit
    WIDGET
creation make
feature
    string : STRING

    put_string(s : STRING) is
    do
	!!string.copy(s)
	cursor := string.count + 1
	update_image
    end

    cursor : INTEGER

    text_insert(c : CHARACTER) is
    do
	string.insert_character(c, cursor)
	update_image
    end

    text_backspace is
    do
	if string.count > 0 and then cursor > 1 then
	    cursor := cursor - 1
	    string.remove(cursor)
	    update_image
	end
    end

    text_delete is
    do
	if string.count > 0 and then cursor <= string.upper then
	    string.remove(cursor)
	    update_image
	end
    end

    is_empty : BOOLEAN is
    do
	Result := string.is_empty
    end

    clear is
    do
	string.clear
	cursor := 1
	update_image
    end

    make is
    do
	widget_init
	!!string.make(128)
	cursor := 1
	!!textimg.make
    end

    process_event(e : EVENT) is
    do
	if e.type = sdl_keydown then
	    process_key(e)
	end
    end

    process_key(e : EVENT) is
    local
	k : INTEGER
    do
	k := e.i1
	if k < 256 and then is_normal_key(k) then
	    if is_kmod(e.kmod, kmod_shift) then
		text_insert(shifted_key(k))
	    else
		text_insert(k.to_character)
	    end
	    cursor := cursor + 1
	elseif k = sdlk_right then
	    cursor := cursor + 1
	    if cursor > string.count + 1 then
		cursor := string.count + 1
	    end
	elseif k = sdlk_left then
	    cursor := cursor - 1
	    if cursor < 1 then
		cursor := 1
	    end
	elseif k = sdlk_backspace then
	    text_backspace
	elseif k = sdlk_delete then
	    text_delete
	elseif k = sdlk_return then
	    raise_signal(signal_activate)
	end
    end

    shifted_key_table : ARRAY[CHARACTER] is
    local
	i : INTEGER
    once
	!!Result.make(0, 127)
	from i := sdlk_a
	until i > sdlk_z
	loop
	    Result.put((i - 32).to_character, i)
	    i := i + 1
	end
	Result.put('~', sdlk_backquote)
	Result.put('!', sdlk_1)
	Result.put('@', sdlk_2)
	Result.put('#', sdlk_3)
	Result.put('$', sdlk_4)
	Result.put('%%', sdlk_5)
	Result.put('^', sdlk_6)
	Result.put('&', sdlk_7)
	Result.put('*', sdlk_8)
	Result.put('(', sdlk_9)
	Result.put(')', sdlk_0)
	Result.put('_', sdlk_minus)
	Result.put('+', sdlk_equals)
	Result.put('|', sdlk_backslash)

	Result.put('{', sdlk_leftbracket)
	Result.put('}', sdlk_rightbracket)

	Result.put(':', sdlk_semicolon)
	Result.put('"', sdlk_quote)

	Result.put('<', sdlk_comma)
	Result.put('>', sdlk_period)
	Result.put('?', sdlk_slash)

	Result.put(' ', sdlk_space)
    end

    shifted_key(k : INTEGER) : CHARACTER is
    do
	if shifted_key_table.item(k) /= '%U' then
	    Result := shifted_key_table.item(k)
	else
	    Result := k.to_character
	end
    end

    is_normal_key(k : INTEGER) : BOOLEAN is
    do
	if shifted_key_table.item(k) /= '%U' then
	    Result := True
	end
    end

    update is
    local
	x : INTEGER
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
	if cursor = 1 then
	    x := 2
	else
	    measure_text_size(string.substring(1, cursor - 1))
	    x := 2 + text_width
	end
	if has_focus then
	    fill_rect(x, 2, 1, height - 4, white)
	end
    end

    textimg : IMAGE

    update_image is
    do
	if textimg.is_connected then
	    textimg.free
	end
	if string.count > 0 then
	    textimg.render_string(string, font, white)
	end
    end
end
