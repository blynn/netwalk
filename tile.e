class TILE
inherit DIR_CONSTANT
creation make, make_server_bottom, make_server_top
feature
    tile_server_top : INTEGER is 1
    tile_server_bottom : INTEGER is 2
    tile_normal : INTEGER is 3
    tile_terminal : INTEGER is 4

    type : INTEGER

    neighbour : ARRAY[BOOLEAN]

    x, y : INTEGER

    put_xy(new_x, new_y : INTEGER) is
    do
	x := new_x
	y := new_y
    end

    is_connected : BOOLEAN

    connect is
    do
	is_connected := True
    end

    disconnect is
    do
	is_connected := False
    end

    neighbour_count : INTEGER

    count_neighbours is
    local
	dir : INTEGER
    do
	from dir := 1
	until dir > 4
	loop
	    if neighbour.item(dir) then
		neighbour_count := neighbour_count + 1
	    end
	    dir := dir + 1
	end

	if neighbour_count = 1 and then
		type = tile_normal then
	    type := tile_terminal
	end
    end

    make is
    do
	type := tile_normal
	!!neighbour.make(1, 4)
    end

    make_server_bottom is
    do
	type := tile_server_bottom
	!!neighbour.make(1, 4)
    end

    make_server_top is
    do
	type := tile_server_top
	!!neighbour.make(1, 4)
    end
end
