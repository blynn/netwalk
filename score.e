class SCORE
creation make
feature
    make(n : STRING; s, t : INTEGER) is
    do
	!!name.copy(n)
	score := s
	time := t
    end

    name : STRING
    put_name(n : STRING) is
    do
	!!name.copy(n)
    end

    score : INTEGER
    put_score(i : like score) is
    do
	score := i
    end

    time : INTEGER
    put_time(i : like time) is
    do
	time := i
    end
end
