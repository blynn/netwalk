expanded class EVENTMAKER
inherit SDL_CONSTANT
feature
    make_keydown(key : INTEGER; kmod : INTEGER) : EVENT is
    do
	!!Result.make
	Result.put_type(sdl_keydown)
	Result.put_i1(key)
	Result.put_kmod(kmod)
    end

    make_mbdown(b : INTEGER; kmod : INTEGER; x, y : INTEGER) : EVENT is
    do
	!!Result.make
	Result.put_type(sdl_mousebuttondown)
	Result.put_i1(b)
	Result.put_kmod(kmod)
	Result.put_xy(x, y)
    end

    make_quit : EVENT is
    do
	!!Result.make
	Result.put_type(sdl_quit)
    end
end
