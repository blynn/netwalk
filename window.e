deferred class WINDOW
inherit
    WIDGET
	redefine
	    widget_init, put_xy
	end
feature
    widget_list : LINKED_LIST[WIDGET]

    add_widget(w : WIDGET; x, y : INTEGER) is
    do
	w.put_xy(offsetx + x, offsety + y)
	widget_list.add_last(w)
    end

    focus_widget : WIDGET

    widget_init is
    do
	Precursor
	!!widget_list.make
    end

    process_event(e : EVENT) is
    local
	it : ITERATOR[WIDGET]
    do
	inspect e.type
	when sdl_mousebuttondown then
	    it := widget_list.get_new_iterator
	    from it.start
	    until it.is_off
	    loop
		if it.item.contains(e.x, e.y) then
		    change_focus(it.item)
		    it.item.process_event(e)
		end
		it.next
	    end
	when sdl_keydown then
	    if e.i1 = sdlk_escape then
		raise_signal(signal_cancel)
	    elseif focus_widget /= Void then
		focus_widget.process_event(e)
	    end
	else
	end
    end

    update is
    do
	fill_rect(0, 0, width, height, green)
	fill_rect(1, 1, width - 2, height - 2, black)
	widget_list.do_all(agent {WIDGET}.update)
    end

    change_focus(w : WIDGET) is
    do
	if focus_widget /= Void then
	    focus_widget.put_focus(False)
	end
	focus_widget := w
	focus_widget.put_focus(True)
    end

    put_xy(x, y : INTEGER) is
    do
	widget_list.do_all(agent move_widget(?, x, y))
	Precursor(x, y)
    end

    move_widget(w : WIDGET; x, y : INTEGER) is
    do
	w.put_xy(w.offsetx - offsetx + x, w.offsety - offsety + y)
    end
end
