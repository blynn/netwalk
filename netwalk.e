--TODO: similar code: get_neighbour, is_surrounded. need TUPLEs?
class NETWALK
inherit DIR_CONSTANT; SDL_CONSTANT; COLOR_TABLE; CONFIG
creation make
feature
    io_score : IO_SCORE

    tile_server_top : INTEGER is 1
    tile_server_bottom : INTEGER is 2
    tile_normal : INTEGER is 3
    tile_terminal : INTEGER is 4

    board : ARRAY2[TILE]

    width : INTEGER is
    do
	Result := current_setting.width
    end

    height : INTEGER is
    do
	Result := current_setting.height
    end

    allow_wrap : BOOLEAN is
    do
	Result := current_setting.wrap
    end

    current_preset : PRESET
    current_setting : SETTING

    use_setting(s : SETTING) is
    do
	!!current_setting.make
	current_setting.copy(s)
    end

    servertopi : INTEGER is
    do
	Result := width // 2
    end
    servertopj : INTEGER is
    do
	Result := height // 2 + 1
    end

    font : TTF_FONT is
    do
	Result := config.bigfont
    end

    mainfont : TTF_FONT is
    do
	Result := config.mainfont
    end

    win_image : IMAGE is
    once
	!!Result.make
	Result.render_string("Well Done", font, white)
    end

    seed : INTEGER
    move_count : INTEGER

    new_game_button : BUTTON
    options_button : BUTTON
    hs_button : BUTTON
    quit_button : BUTTON

    options_window : OPTIONS_WINDOW
    newhs_window : NEWHS_WINDOW
    hs_window : HS_WINDOW

    widget_list : LINKED_LIST[WIDGET]

    add_widget(w : WIDGET; x, y : INTEGER) is
    do
	widget_list.add_last(w)
	w.put_xy(x, y)
    end

    elapsed_seconds : INTEGER
    elapsed_ticks : INTEGER
    last_ticks : INTEGER

    make is
    local
	c : COMMAND
	time : TIME
    do
	!!widget_list.make
	time.update
	seed := time.hour * 3600 + time.minute * 60 + time.second
	!!rand.with_seed(seed)
	ext_init
	connected_pipe_color := green
	disconnected_pipe_color := darkred
	connected_terminal_color := cyan
	disconnected_terminal_color := darkpurple
	current_preset := config.get_preset(config.default_preset)
	use_setting(current_preset.setting)
	!!move_image.make
	move_image.new_dummy

	!!best_image.make
	best_image.new_dummy

	!!time_image.make
	time_image.new_dummy

	!!new_game_button.make("New Game")
	new_game_button.put_size(80, 20)
	!COMMAND_NEW_GAME!c.make(Current)
	new_game_button.put_command(c, new_game_button.signal_activate)
	add_widget(new_game_button, 550, 20)

	!!options_button.make("Options")
	options_button.put_size(80, 20)
	!COMMAND_OPTIONS!c.make(Current)
	options_button.put_command(c, options_button.signal_activate)
	add_widget(options_button, 550, 60)

	!!hs_button.make("High Scores")
	hs_button.put_size(80, 20)
	!COMMAND_SHOW_HS!c.make(Current)
	hs_button.put_command(c, hs_button.signal_activate)
	add_widget(hs_button, 550, 100)

	!!quit_button.make("Quit")
	quit_button.put_size(80, 20)
	!COMMAND_QUIT!c.make(Current)
	quit_button.put_command(c, quit_button.signal_activate)
	add_widget(quit_button, 550, 140)

	!!io_score.make
	io_score.load(config.score_file)
	io_score.into_preset_list(config.preset_list)

	make_options_window
	make_newhs_window
	make_hs_window

	new_game
	main_loop
    end

    make_options_window is
    local
	c : COMMAND
    do
	!!options_window.make
	!COMMAND_OPTIONS_OK!c.make(Current)
	options_window.put_command(c, options_window.signal_activate)
	!COMMAND_CLOSE_CURRENT!c.make(Current)
	options_window.put_command(c, options_window.signal_cancel)
	options_window.put_xy(200, 100)
	options_window.put_preset_list(config.preset_list)
    end

    make_newhs_window is
    local
	c : COMMAND
    do
	!!newhs_window.make
	!COMMAND_NEWHS_OK!c.make(Current)
	newhs_window.put_command(c, newhs_window.signal_activate)
	newhs_window.put_xy(200, 100)
    end

    make_hs_window is
    local
	c : COMMAND
    do
	!!hs_window.make
	!COMMAND_CLOSE_CURRENT!c.make(Current)
	hs_window.put_command(c, hs_window.signal_activate)
	hs_window.put_xy(200, 100)
	hs_window.init_scores(config.preset_list)
    end

    close_current_window is
    require
	current_window /= Void
    do
	current_window := Void
    end

    show_hs is
    require
	current_window = Void
    do
	current_window := hs_window
    end

    newhs_ok is
    require
	current_window = newhs_window
    local
	s : STRING
    do
	current_window := Void
	s := newhs_window.name_tb.string
	current_preset.hiscore.put_name(s)
	hs_window.update_score(current_preset)
	io_score.from_preset_list(config.preset_list)
	io_score.save(config.score_file)
    end

    options_ok is
    require
	current_window = options_window
    do
	current_window := Void
	options_window.update_setting
	if current_preset /= options_window.preset then
	    current_preset := options_window.preset
	    use_setting(options_window.setting)
	    new_game
	elseif not current_setting.is_equal(options_window.setting) then
	    use_setting(options_window.setting)
	    new_game
	end
    end

    new_game is
    do
	rand.with_seed(seed)
	!!board.make(1, width, 1, height)
	generate_board
	preprocess_board
	reset_score
	scramble_board
	update_best_image
	reset_score
	game_state := state_playing
	last_ticks := get_ticks
	elapsed_seconds := 0
	update_time_image
	elapsed_ticks := 0
    end

    options is
    do
	current_window := options_window
	options_window.put_info(current_preset, current_setting)
    end

    state_none : INTEGER is 0
    state_playing : INTEGER is 1
    state_victory : INTEGER is 2
    state_quit : INTEGER is 3
    game_state : INTEGER

    current_window : WINDOW

    main_loop is
    local
	e : EVENT
	i : INTEGER
    do
	from
	until game_state = state_quit
	loop
	    seed := seed + 1
	    blank_screen

	    widget_list.do_all(agent {WIDGET}.update)
	    draw_border
	    if game_state = state_playing then
		i := get_ticks
		elapsed_ticks := elapsed_ticks + i - last_ticks
		last_ticks := i
		i := elapsed_ticks // 1000
		if i > elapsed_seconds then
		    elapsed_seconds := i
		    update_time_image
		end

		draw_board
		check_connections
		if is_victorious then
		    game_state := state_victory
		    hiscore_check
		end
	    end
	    if game_state = state_victory then
		draw_board
		win_image.blit(10, 0)
	    end

	    best_image.blit(10, 420)
	    move_image.blit(10, 440)
	    time_image.blit(10, 460)

	    if current_window /= Void then
		current_window.update
	    end

	    ext_update_screen
	    e := poll_event
	    if e /= Void then
		if current_window /= Void then
		    current_window.process_event(e)
		else
		    handle_event(e)
		end
	    end
	end
    end

    hiscore_check is
    local
	newhi : BOOLEAN
	score : INTEGER
	hiscore : SCORE
    do
	score := move_count - best
	if current_preset /= Void then
	    hiscore := current_preset.hiscore
	    if hiscore = Void then
		newhi := True
	    elseif hiscore.time > elapsed_seconds then
		newhi := True
	    elseif hiscore.time = elapsed_seconds and then hiscore.score > score then
		newhi := True
	    end
	    if newhi then
		!!hiscore.make("Anonymous", score, elapsed_seconds)
		current_preset.put_hiscore(hiscore)
		current_window := newhs_window
		newhs_window.name_tb.put_string(hiscore.name)
	    end
	end
    end

    quit is
    do
	game_state := state_quit
    end
    
    handle_event(e : EVENT) is
    do
	inspect e.type
	when sdl_keydown then
	    inspect e.i1
	    when sdlk_f2 then
		new_game
	    else
	    end
	when sdl_mousebuttondown then
	    handle_mbdown(e)
	when sdl_quit then
	    quit
	else
	end
    end

    handle_mbdown(e : EVENT) is
    local
	i, j : INTEGER
	it : ITERATOR[WIDGET]
    do
	it := widget_list.get_new_iterator
	from it.start
	until it.is_off
	loop
	    if it.item.contains(e.x, e.y) then
		it.item.process_event(e)
	    end
	    it.next
	end
	if game_state = state_playing then
	    i := e.x // cellwidth
	    j := e.y // cellheight
	    if on_board(i, j) then
		if e.i1 = 1 then
		    rotateccw(i, j)
		else
		    rotatecw(i, j)
		end
	    end
	end
    end

    move_image : IMAGE
    best_image : IMAGE
    time_image : IMAGE

    reset_score is
    do
	move_count := 0
	move_image.free
	move_image.render_string("moves: " + move_count.to_string, mainfont, white)
    end

    tally_move is
    do
	move_count := move_count + 1
	move_image.free
	move_image.render_string("moves: " + move_count.to_string, mainfont, white)
    end

    update_best_image is
    do
	best_image.free
	best_image.render_string("par: " + best.to_string, mainfont, white)
    end

    update_time_image is
    do
	time_image.free
	time_image.render_string("time: " + elapsed_seconds.to_string, mainfont, white)
    end

    rotatecw(i, j : INTEGER) is
    local
	t : TILE
	dir : INTEGER
	bak : BOOLEAN
    do
	t := board.item(i, j)
	if t /= Void then
	    if t = server_top or else t = server_bottom then
		bak := server_top.neighbour.item(1)
		server_top.neighbour.put(server_bottom.neighbour.item(4), 1)
		server_bottom.neighbour.put(server_bottom.neighbour.item(3), 4)
		server_bottom.neighbour.put(server_bottom.neighbour.item(2), 3)
		server_bottom.neighbour.put(bak, 2)
	    else
		bak := t.neighbour.item(4)
		from dir := 4
		until dir = 1
		loop
		    t.neighbour.put(t.neighbour.item(dir - 1), dir)
		    dir := dir - 1
		end
		t.neighbour.put(bak, dir)
	    end
	    tally_move
	end
    end

    rotateccw(i, j : INTEGER) is
    local
	t : TILE
	dir : INTEGER
	bak : BOOLEAN
    do
	t := board.item(i, j)
	if t /= Void then
	    if t = server_top or else t = server_bottom then
		bak := server_top.neighbour.item(1)
		server_top.neighbour.put(server_bottom.neighbour.item(2), 1)
		server_bottom.neighbour.put(server_bottom.neighbour.item(3), 2)
		server_bottom.neighbour.put(server_bottom.neighbour.item(4), 3)
		server_bottom.neighbour.put(bak, 4)
	    else
		bak := t.neighbour.item(1)
		from dir := 1
		until dir = 4
		loop
		    t.neighbour.put(t.neighbour.item(dir + 1), dir)
		    dir := dir + 1
		end
		t.neighbour.put(bak, dir)
	    end
	    tally_move
	end
    end

    server_top, server_bottom : TILE

    preprocess_board is
    local
	i, j : INTEGER
	t : TILE
    do
	from i := 1
	until i > width
	loop
	    from j := 1
	    until j > height
	    loop
		t := board.item(i, j)
		if t /= Void then
		    t.count_neighbours
		end
		j := j + 1
	    end
	    i := i + 1
	end
    end

    draw_board is
    local
	i, j : INTEGER
    do
	from i := 1
	until i > width
	loop
	    from j := 1
	    until j > height
	    loop
		draw_tile(board.item(i, j))
		j := j + 1
	    end
	    i := i + 1
	end
    end

    draw_border is
    local
	i : INTEGER
    do
	from i := 1
	until i > width + 1
	loop
	    fill_rect(i * cellwidth, cellheight, 1, height * cellheight, blue)
	    i := i + 1
	end

	from i := 1
	until i > height + 1
	loop
	    fill_rect(cellwidth, i * cellheight, width * cellwidth, 1, blue)
	    i := i + 1
	end
    end

    cellwidth : INTEGER is 32
    cellheight : INTEGER is 32
    uppipex : INTEGER is 13
    uppipew : INTEGER is 6
    uppipeh : INTEGER is 19
    leftpipey : INTEGER is 13
    leftpipew : INTEGER is 19
    leftpipeh : INTEGER is 6

    check_connections is
    local
	check_list : LINKED_LIST[TILE]
	i, j : INTEGER
	dir : INTEGER
	t, t2 : TILE
    do
	from i := 1
	until i > width
	loop
	    from j := 1
	    until j > height
	    loop
		t := board.item(i, j)
		if t /= Void then
		    t.disconnect
		end
		j := j + 1
	    end
	    i := i + 1
	end

	!!check_list.make
	check_list.add_last(server_top)
	check_list.add_last(server_bottom)
	server_top.connect
	server_bottom.connect

	from
	until check_list.is_empty
	loop
	    t := check_list.first
	    check_list.remove_first
	    from dir := 1
	    until dir > 4
	    loop
		if t.neighbour.item(dir) then
		    t2 := get_neighbour(t, dir)
		    if t2 /= Void and then
			    t2.neighbour.item(dir_opposite(dir)) and then
			    not t2.is_connected then
			t2.connect
			check_list.add_last(t2)
		    end
		end
		dir := dir + 1
	    end
	end
    end

    is_victorious : BOOLEAN is
    local
	i, j : INTEGER
	t : TILE
    do
	Result := True
	from i := 1
	until i > width or else not Result
	loop
	    from j := 1
	    until j > height or else not Result
	    loop
		t := board.item(i, j)
		if t /= Void and then not t.is_connected then
		    Result := False
		end
		j := j + 1
	    end
	    i := i + 1
	end
    end
    
    maybe_wrapx(i : INTEGER) : INTEGER is
    do
	Result := i
	if allow_wrap then
	    if i < 1 then
		Result := i + width
	    elseif i > width then
		Result := i - width
	    end
	end
    end

    maybe_wrapy(i : INTEGER) : INTEGER is
    do
	Result := i
	if allow_wrap then
	    if i < 1 then
		Result := i + height
	    elseif i > height then
		Result := i - height
	    end
	end
    end

    get_neighbour(t : TILE; dir : INTEGER) : TILE is
    local
	x, y : INTEGER
	x1, y1 : INTEGER
    do
	if dir = dir_up then
	    y1 := -1
	elseif dir = dir_down then
	    y1 := 1
	end

	if dir = dir_left then
	    x1 := -1
	elseif dir = dir_right then
	    x1 := 1
	end
	x := maybe_wrapx(t.x + x1)
	y := maybe_wrapy(t.y + y1)
	if on_board(x, y) then
	    Result := board.item(x, y)
	end
    end

    on_board(x, y : INTEGER) : BOOLEAN is
    do
	Result := x >= 1 and then x <= width
		and then y >= 1 and then y <= height
    end

    connected_pipe_color : COLOR
    disconnected_pipe_color : COLOR
    connected_terminal_color : COLOR
    disconnected_terminal_color : COLOR

    draw_tile(tile : TILE) is
    local
	x : INTEGER
	y : INTEGER
	c, c2 : COLOR
    do
	if tile /= Void then
	    x := tile.x * cellwidth
	    y := tile.y * cellheight
	    if tile.is_connected then
		c := connected_pipe_color
		c2 := connected_terminal_color
	    else
		c := disconnected_pipe_color
		c2 := disconnected_terminal_color
	    end

	    if tile.neighbour.item(dir_up) then
		fill_rect(x + uppipex, y, uppipew, uppipeh, c)
	    end
	    if tile.neighbour.item(dir_left) then
		fill_rect(x, y + leftpipey, leftpipew, leftpipeh, c)
	    end
	    if tile.neighbour.item(dir_right) then
		fill_rect(x + uppipex, y + leftpipey, leftpipew, leftpipeh, c)
	    end
	    if tile.neighbour.item(dir_down) then
		fill_rect(x + uppipex, y + leftpipey, uppipew, uppipeh, c)
	    end

	    inspect tile.type
	    when tile_server_top then
		fill_rect(x + 7, y + 7, cellwidth - 12, cellheight - 6, blue)
	    when tile_server_bottom then
		fill_rect(x + 7, y, cellwidth - 12, cellheight - 6, blue)
	    when tile_terminal then
		fill_rect(x + 8, y + 8, 16, 16, c2)
	    else
	    end

	end
    end

    ext_fill_rect(x, y, w, h : INTEGER; c : INTEGER) is
    external "C"
    end

    wrap_flag : BOOLEAN

    open_list : LINKED_LIST[TILE]

    rand : STD_RAND

    generate_board is
    local
	i : INTEGER
	t : TILE
    do
	--place server
	!!server_bottom.make_server_bottom
	place_tile(server_bottom, servertopi, servertopj + 1)
	!!server_top.make_server_top
	place_tile(server_top, servertopi, servertopj)

	--generate maze
	!!open_list.make
	open_list.add_last(server_top)
	open_list.add_last(server_bottom)

	from
	until open_list.is_empty
	loop
	    rand.next
	    i := rand.last_integer(open_list.count)
	    t := open_list @ i
	    rand.next
	    i := rand.last_integer(4)
	    try_extend(t, i)
	end
    end

    best : INTEGER

    scramble_board is
    local
	i, j : INTEGER
	sym2, sym4 : BOOLEAN
    do
	best := 0
	from i := 1
	until i > width
	loop
	    from j := 1
	    until j > height
	    loop
		if board.item(i, j) /= server_top then
		    sym2 := False
		    sym4 := False
		    if board.item(i, j) = server_bottom and then
server_top.neighbour.item(dir_up) = server_bottom.neighbour.item(dir_down) and then
server_bottom.neighbour.item(dir_left) = server_bottom.neighbour.item(dir_right) then
			sym2 := True
			if server_top.neighbour.item(dir_up) = server_bottom.neighbour.item(dir_right) then
			    sym4 := True
			end
		    elseif board.item(i, j).is_symmetric then
			sym2 := True
		    end

		    rand.next
		    inspect rand.last_integer(4)
		    when 1 then
			rotateccw(i, j)
			if not sym4 then
			    best := best + 1
			end
		    when 2 then
			rotatecw(i, j)
			if not sym4 then
			    best := best + 1
			end
		    when 3 then
			rotatecw(i, j)
			rotatecw(i, j)
			if not sym2 then
			    best := best + 2
			end
		    else
		    end
		end
		j := j + 1
	    end
	    i := i + 1
	end
    end
    
    try_extend(t : TILE; dir : INTEGER) is
    local
	x, y : INTEGER
	x1, y1 : INTEGER
	t2 : TILE
	i : INTEGER
    do
	if dir = dir_up then
	    y1 := -1
	elseif dir = dir_down then
	    y1 := 1
	end

	if dir = dir_left then
	    x1 := -1
	elseif dir = dir_right then
	    x1 := 1
	end
    
	x := maybe_wrapx(t.x + x1)
	y := maybe_wrapy(t.y + y1)

	if on_board(x, y) then
	    t2 := board.item(x, y)
	    if t = server_top and then (dir = dir_left or else dir = dir_right) then
	    elseif t2 /= Void then
	    else
		!!t2.make
		place_tile(t2, x, y)
		t.neighbour.put(True, dir)
		t2.neighbour.put(True, dir_opposite(dir))
		open_list.add_last(t2)

		from i := open_list.lower
		until i > open_list.upper
		loop
		    if is_surrounded(open_list @ i) then
			open_list.remove(i)
		    else
			i := i + 1
		    end
		end
	    end
	end
    end

    is_surrounded(t : TILE) : BOOLEAN is
    local
	dir : INTEGER
	x, y : INTEGER
	x1, y1 : INTEGER
	count : INTEGER
    do
	Result := True
	from dir := 1
	until dir > 4
	loop
	    if t.neighbour.item(dir) then
		count := count + 1
	    end
	    y1 := 0
	    if dir = dir_up then
		y1 := -1
	    elseif dir = dir_down then
		y1 := 1
	    end

	    x1 := 0
	    if dir = dir_left then
		x1 := -1
	    elseif dir = dir_right then
		x1 := 1
	    end
	
	    x := maybe_wrapx(t.x + x1)
	    y := maybe_wrapy(t.y + y1)

	    if on_board(x, y) then
		if board.item(x, y) = Void then
		    if t = server_top then
			if dir /= dir_left and then dir /= dir_right then
			    Result := False
			end
		    else
			Result := False
		    end
		end
	    end
	    dir := dir + 1
	end
	if count >= 3 then
	    Result := True
	end
    end

    place_tile(tile : TILE; x, y : INTEGER) is
    do
	tile.put_xy(x, y)
	board.put(tile, x, y)
    end

    poll_event : EVENT is
    local
	em : EVENTMAKER
    do
	Result := ext_poll_event(em)
    end

    ext_init is
    external "C"
    end

    ext_poll_event(em : EVENTMAKER) : EVENT is
    external "C" alias "ext_poll_event"
    end

    get_ticks : INTEGER is
    external "C" alias "ext_get_ticks"
    end

    ext_update_screen is
    external "C"
    end

    fill_rect(x, y, w, h : INTEGER; c : COLOR) is
    do
	--ext_fill_rect(x + offsetx, y + offsety, w, h, c.to_integer)
	ext_fill_rect(x, y, w, h, c.to_integer)
    end

    blank_screen is
    do
	fill_rect(0, 0, 640, 480, black)
    end
end
