class OPTIONS_WINDOW
inherit
    WIDGET
creation make
feature
    widget_list : LINKED_LIST[WIDGET]

    add_widget(w : WIDGET) is
    do
	w.put_xy(offsetx + w.offsetx, offsety + w.offsety)
	widget_list.add_last(w)
    end

    focus_widget : WIDGET

    wrap_cb : CHECKBOX
    width_tb : TEXTBOX
    height_tb : TEXTBOX

    make is
    local
	b : BUTTON
	c : COMMAND
	l : LABEL
    do
	widget_init
	!!widget_list.make
	put_geometry(200, 100, 200, 200)
	!!b.make("Ok")
	b.put_geometry(30, 175, 60, 20)
	!COMMAND_ACTIVATE!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b)

	!!b.make("Cancel")
	b.put_geometry(95, 175, 60, 20)
	!COMMAND_CANCEL!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b)

	!!l.make("Width")
	l.put_geometry(10, 10, 50, 20)
	add_widget(l)
	!!width_tb.make
	width_tb.put_geometry(70, 10, 50, 16)
	add_widget(width_tb)

	!!l.make("Height")
	l.put_geometry(10, 30, 50, 20)
	add_widget(l)
	!!height_tb.make
	height_tb.put_geometry(70, 30, 50, 16)
	add_widget(height_tb)

	!!l.make("Wrap")
	l.put_geometry(10, 50, 50, 20)
	add_widget(l)
	!!wrap_cb.make
	wrap_cb.put_geometry(75, 55, 12, 12)
	add_widget(wrap_cb)
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
end
