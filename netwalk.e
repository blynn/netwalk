--TODO: similar code: get_neighbour, is_surrounded. need TUPLEs?
class NETWALK
inherit DIR_CONSTANT; SDL_CONSTANT; COLOR_TABLE; CONFIG
creation make
feature
    tile_server_top : INTEGER is 1
    tile_server_bottom : INTEGER is 2
    tile_normal : INTEGER is 3
    tile_terminal : INTEGER is 4

    board : ARRAY2[TILE]
    width : INTEGER
    height : INTEGER
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

    win_image : IMAGE is
    once
	!!Result.make
	Result.render_string("Well Done", font, white)
    end

    allow_wrap : BOOLEAN
    difficulty : INTEGER

    seed : INTEGER

    make is
    do
	!!rand.make
	ext_init
	connected_pipe_color := green
	disconnected_pipe_color := darkred
	connected_terminal_color := cyan
	disconnected_terminal_color := darkpurple
	width := 10
	height := 9
	main_loop
    end

    new_game is
    do
	rand.with_seed(seed)
	!!board.make(1, width, 1, height)
	generate_board
	preprocess_board
	scramble_board
	game_state := state_playing
	if difficulty > 0 then
	    allow_wrap := True
	else
	    allow_wrap := False
	end
    end

    state_none : INTEGER is 0
    state_playing : INTEGER is 1
    state_victory : INTEGER is 2
    state_quit : INTEGER is 3
    game_state : INTEGER

    main_loop is
    local
	e : EVENT
    do
	from
	until game_state = state_quit
	loop
	    seed := seed + 1
	    blank_screen
	    draw_border
	    if game_state = state_playing then
		draw_board
		if check_connections then
		    game_state := state_victory
		end
	    end
	    if game_state = state_victory then
		draw_board
		win_image.blit(50, 400)
	    end
	    ext_update_screen
	    e := poll_event
	    if e /= Void then
		handle_event(e)
	    end
	end
    end
    
    handle_event(e : EVENT) is
    do
	inspect e.type
	when sdl_keydown then
	    inspect e.i1
	    when sdlk_escape then
		game_state := state_quit
	    when sdlk_f3 then
		difficulty := difficulty + 1
		if difficulty > 1 then
		    difficulty := 0
		end
	    when sdlk_f2 then
		new_game
	    else
	    end
	when sdl_mousebuttondown then
	    handle_mbdown(e)
	else
	end
    end

    handle_mbdown(e : EVENT) is
    local
	i, j : INTEGER
    do
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

    rotatecw(i, j : INTEGER) is
    local
	t : TILE
	dir : INTEGER
	bak : BOOLEAN
    do
	t := board.item(i, j)
	if t = server_top or else t = server_bottom then
	    bak := server_top.neighbour.item(1)
	    server_top.neighbour.put(server_bottom.neighbour.item(4), 1)
	    server_bottom.neighbour.put(server_bottom.neighbour.item(3), 4)
	    server_bottom.neighbour.put(server_bottom.neighbour.item(2), 3)
	    server_bottom.neighbour.put(bak, 2)
	elseif t /= Void then
	    bak := t.neighbour.item(4)
	    from dir := 4
	    until dir = 1
	    loop
		t.neighbour.put(t.neighbour.item(dir - 1), dir)
		dir := dir - 1
	    end
	    t.neighbour.put(bak, dir)
	end
    end

    rotateccw(i, j : INTEGER) is
    local
	t : TILE
	dir : INTEGER
	bak : BOOLEAN
    do
	t := board.item(i, j)
	if t = server_top or else t = server_bottom then
	    bak := server_top.neighbour.item(1)
	    server_top.neighbour.put(server_bottom.neighbour.item(2), 1)
	    server_bottom.neighbour.put(server_bottom.neighbour.item(3), 2)
	    server_bottom.neighbour.put(server_bottom.neighbour.item(4), 3)
	    server_bottom.neighbour.put(bak, 4)
	elseif t /= Void then
	    bak := t.neighbour.item(1)
	    from dir := 1
	    until dir = 4
	    loop
		t.neighbour.put(t.neighbour.item(dir + 1), dir)
		dir := dir + 1
	    end
	    t.neighbour.put(bak, dir)
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

    check_connections : BOOLEAN is
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

	--victory check
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
		fill_rect(x + 5, y + 5, cellwidth - 10, cellheight - 5, blue)
	    when tile_server_bottom then
		fill_rect(x + 5, y, cellwidth - 10, cellheight - 5, blue)
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
    do
	best := 0
	from i := 1
	until i > width
	loop
	    from j := 1
	    until j > height
	    loop
		if board.item(i, j) /= server_top then
		    rand.next
		    inspect rand.last_integer(4)
		    when 1 then
			rotateccw(i, j)
			best := best + 1
		    when 2 then
			rotatecw(i, j)
			best := best + 1
		    when 3 then
			rotatecw(i, j)
			rotatecw(i, j)
			best := best + 2
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
