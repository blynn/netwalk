class CONFIG_DATA
creation make
feature
    config_file : STRING is "config"

    mainttf : STRING
    bigttf : STRING

    mainfont : TTF_FONT
    bigfont : TTF_FONT

    make is
    do
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

    read_config(in : TEXT_FILE_READ) is
    local
	s1, s2 : STRING
    do
	from in.read_word
	until in.end_of_input
	loop
	    s1 := clone(in.last_string)
	    if not in.end_of_input then
		in.read_line
		s2 := clone(in.last_string)
	    else
		!!s2.copy("")
	    end
	    if s1.first = '#' then
	    elseif s1.is_equal("main_font") then
		mainttf := s2
	    elseif s1.is_equal("big_font") then
		bigttf := s2
	    end
	    in.read_word
	end

	!!mainfont.load(mainttf, 12)
	!!bigfont.load(bigttf, 24)
    end
end
