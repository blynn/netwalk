class SETTING
inherit
    ANY
	redefine
	    is_equal, copy
	end
creation make
feature
    default_width : INTEGER is 10
    default_height : INTEGER is 9

    min_width : INTEGER is 4
    max_width : INTEGER is 15

    min_height : INTEGER is 4
    max_height : INTEGER is 13

    width : INTEGER
    put_width(i : INTEGER) is
    require
	i >= min_width
	i <= max_width
    do
	width := i
    end

    height : INTEGER
    put_height(i : INTEGER) is
    require
	i >= min_height
	i <= max_height
    do
	height := i
    end

    wrap : BOOLEAN
    put_wrap(b : BOOLEAN) is
    do
	wrap := b
    end

    is_equal(o : like Current) : BOOLEAN is
    do
	if height = o.height and then
		width = o.width and then
		wrap = o.wrap then
	    Result := True
	end
    end

    copy(o : like Current) is
    do
	put_height(o.height)
	put_width(o.width)
	put_wrap(o.wrap)
    end

    make is
    do
	put_height(default_height)
	put_width(default_width)
    end

--TODO: similar code
    clip_width(i : INTEGER) : INTEGER is
    do
	if i < min_width then
	    Result := min_width
	elseif i > max_width then
	    Result := max_width
	else
	    Result := i
	end
    end

    clip_height(i : INTEGER) : INTEGER is
    do
	if i < min_height then
	    Result := min_height
	elseif i > max_height then
	    Result := max_height
	else
	    Result := i
	end
    end
end
