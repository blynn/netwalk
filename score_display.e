class SCORE_DISPLAY
creation make
feature
    name : STRING
    level_l : LABEL
    name_l : LABEL
    time_l : LABEL
    score_l : LABEL

    make(n : STRING; s : SCORE) is
    do
	!!name.copy(n)
	!!level_l.make(n)
	level_l.put_size(70, 20)

	if s /= Void then
	    !!name_l.make(s.name)
	    !!time_l.make(s.time.to_string)
	    !!score_l.make(s.score.to_string)
	else
	    !!name_l.make("none")
	    !!time_l.make("none")
	    !!score_l.make("none")
	end
	name_l.put_size(50, 20)
	time_l.put_size(50, 20)
	score_l.put_size(50, 20)
    end
end
