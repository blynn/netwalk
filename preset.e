class PRESET
creation make
feature
    name : STRING
    setting : SETTING

    make(s : STRING; w, h : INTEGER; wrap : BOOLEAN) is
    do
	!!name.copy(s)
	!!setting.make
	setting.put_width(w)
	setting.put_height(h)
	setting.put_wrap(wrap)
    end

    hiscore : SCORE
    put_hiscore(s : SCORE) is
    do
	hiscore := s
    end
end
