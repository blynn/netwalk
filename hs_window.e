class HS_WINDOW
inherit
    WINDOW
creation make
feature
    row_count : INTEGER
    score_list : LINKED_LIST[SCORE_DISPLAY]

    init_scores(l : LINKED_LIST[PRESET]) is
    do
	!!score_list.make
	l.do_all(agent add_new_score(?))
    end

    add_new_score(p : PRESET) is
    local
	sc : SCORE
	sd : SCORE_DISPLAY
	x, y : INTEGER
    do
	sc := p.hiscore
	!!sd.make(p.name, sc)
	x := 10
	y := row_count * 20 + 50
	row_count := row_count + 1
	add_widget(sd.level_l, x, y)
	add_widget(sd.name_l, 70 + x, y)
	add_widget(sd.score_l, 120 + x, y)
	add_widget(sd.time_l, 170 + x, y)
	score_list.add_last(sd)
    end

    update_score(p : PRESET) is
    local
	it : ITERATOR[SCORE_DISPLAY]
	sc : SCORE
	sd : SCORE_DISPLAY
    do
	it := score_list.get_new_iterator
	from it.start
	until it.is_off
	loop
	    sd := it.item
	    if sd.name.is_equal(p.name) then
		sc := p.hiscore
		sd.name_l.put_string(sc.name)
		sd.time_l.put_string(sc.time.to_string)
		sd.score_l.put_string(sc.score.to_string)
	    end
	    it.next
	end
    end

    make is
    local
	b : BUTTON
	c : COMMAND
	l : LABEL
	x, y : INTEGER
    do
	widget_init

	put_size(250, 200)
	!!b.make("Ok")
	b.put_size(60, 20)
	!COMMAND_ACTIVATE!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b, 100, 175)

	x := 10
	y := 5

	!!l.make("Level")
	l.put_size(70, 20)
	add_widget(l, x, y)

	!!l.make("Name")
	l.put_size(50, 20)
	add_widget(l, 70 + x, y)

	!!l.make("Score")
	l.put_size(50, 20)
	add_widget(l, 120 + x, y)

	!!l.make("Time")
	l.put_size(50, 20)
	add_widget(l, 170 + x, y)
    end
end
