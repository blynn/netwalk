class CONFIG_DATA
creation make
feature
    config_file : STRING is "config"
    score_file : STRING

    preset_list : LINKED_LIST[PRESET]

    mainttf : STRING
    bigttf : STRING

    mainfont : TTF_FONT
    bigfont : TTF_FONT

    default_preset : STRING

    has_preset(s : STRING) : BOOLEAN is
    local
	it : ITERATOR[PRESET]
    do
	it := preset_list.get_new_iterator
	from it.start
	until it.is_off
	loop
	    if it.item.name.is_equal(s) then
		Result := True
	    end
	    it.next
	end
    end

    get_preset(s : STRING) : PRESET is
    local
	it : ITERATOR[PRESET]
    do
	it := preset_list.get_new_iterator
	from it.start
	until it.is_off
	loop
	    if it.item.name.is_equal(s) then
		Result := it.item
	    end
	    it.next
	end
    end

    make is
    do
	!!preset_list.make
	load_config
    end

    load_config is
    local
	in : TEXT_FILE_READ
    do
	!!in.connect_to(config_file)
	if not in.is_connected then
	    io.put_string("couldn't read config file%N")
	    die_with_code(1)
	else
	    read_config(in)
	end
	in.disconnect
    end

    state_none : INTEGER is 0
    state_unknown : INTEGER is 1
    state_preset : INTEGER is 2

    read_config(in : TEXT_FILE_READ) is
    local
	s1, s2 : STRING
	state : INTEGER
    do
	from in.read_word
	until in.end_of_input
	loop
	    s1 := clone(in.last_string)
	    in.read_line
	    if not in.end_of_input then
		s2 := clone(in.last_string)
		in.read_word
	    else
		!!s2.copy("")
	    end

	    if s1.first = '#' then
	    elseif s1.is_equal("begin") then
		state := state_unknown
		if s2.is_equal("preset") then
		    state := state_preset
		end
	    elseif s1.is_equal("end") then
		state := state_none
	    else
		inspect state
		when state_none then
		    if s1.is_equal("main_font") then
			mainttf := s2
		    elseif s1.is_equal("big_font") then
			bigttf := s2
		    elseif s1.is_equal("default_preset") then
			default_preset := s2
		    elseif s1.is_equal("hiscores") then
			score_file := s2
		    end
		when state_preset then
		    parse_preset(s1, s2)
		else
		end
	    end
	end

	!!mainfont.load(mainttf, 12)
	!!bigfont.load(bigttf, 24)
    end

    parse_preset(s1, s2 : STRING) is
    local
	p : PRESET
	args : ARRAY[STRING]
	width, height : INTEGER
	wrap : BOOLEAN
    do
	args := s2.split
	width := args.item(1).to_integer
	height := args.item(2).to_integer
	wrap := args.item(3).to_integer /= 0
	!!p.make(s1, width, height, wrap)
	preset_list.add_last(p)
    end
end
