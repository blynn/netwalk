class EVENT
creation make
feature
	x, y : INTEGER
	type : INTEGER
	i1, i2 : INTEGER
	kmod : INTEGER

	make is
	do
	end

	put_xy(x0, y0 : INTEGER) is
	do
		x := x0
		y := y0
	end

	put_type(i : INTEGER) is
	do
		type := i
	end

	put_i1(i : INTEGER) is
	do
		i1 := i
	end

	put_i2(i : INTEGER) is
	do
		i2 := i
	end

	put_kmod(i : INTEGER) is
	do
		kmod := i
	end
end
