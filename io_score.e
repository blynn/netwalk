class IO_SCORE
creation make
feature
    make is
    do
	!!score_table.make
    end

    score_table : DICTIONARY[SCORE, STRING]

    tfr : TEXT_FILE_READ

    load(filename : STRING) is
    do
	!!tfr.connect_to(filename)
	if tfr.is_connected then
	    parse_scores
	    tfr.disconnect
	end
    end

    parse_scores is
    local
	level : STRING
	sc : SCORE
	n : STRING
	i, j : INTEGER
    do
	tfr.read_word
	from
	until tfr.end_of_input
	loop
	    !!level.copy(tfr.last_string)
	    tfr.read_word
	    !!n.copy(tfr.last_string)
	    tfr.read_word
	    i := tfr.last_string.to_integer
	    tfr.read_word
	    j := tfr.last_string.to_integer
	    !!sc.make(n, i, j)
	    score_table.put(sc, level)
	    tfr.read_word
	end
    end

    into_preset_list(l : LINKED_LIST[PRESET]) is
    do
	l.do_all(agent export_score(?))
    end

    export_score(p : PRESET) is
    do
	if score_table.has(p.name) then
	    p.put_hiscore(score_table.at(p.name))
	end
    end

    from_preset_list(l : LINKED_LIST[PRESET]) is
    do
	l.do_all(agent import_score(?))
    end

    import_score(p : PRESET) is
    do
	if p.hiscore /= Void then
	    score_table.put(p.hiscore, p.name)
	end
    end

    tfw : TEXT_FILE_WRITE

    save(filename : STRING) is
    do
	!!tfw.connect_to(filename)
	score_table.do_all(agent write_score(?, ?))
	tfw.disconnect
    end

    write_score(sc : SCORE; level : STRING) is
    do
	tfw.put_string(level + " " + sc.name + " ")
	tfw.put_string(sc.score.to_string + " " + sc.time.to_string + "%N")
    end
end
