deferred class DIR_CONSTANT
feature
    dir_up : INTEGER is 1
    dir_right : INTEGER is 2
    dir_down : INTEGER is 3
    dir_left : INTEGER is 4

    dir_opposite(dir : INTEGER) : INTEGER is
    do
	inspect dir
	when dir_up then
	    Result := dir_down
	when dir_down then
	    Result := dir_up
	when dir_left then
	    Result := dir_right
	when dir_right then
	    Result := dir_left
	end
    end
end
