class OPTIONS_WINDOW
inherit
    WINDOW
creation make
feature
    preset_lb : LISTBOX
    wrap_cb : CHECKBOX
    width_tb : TEXTBOX
    height_tb : TEXTBOX

    setting : SETTING
    preset : PRESET
    preset_list : LINKED_LIST[PRESET]

    custom : SETTING is
    once
	!!Result.make
    end

    put_preset_list(l : LINKED_LIST[PRESET]) is
    local
	it : ITERATOR[PRESET]
	sl : LINKED_LIST[STRING]
    do
	!!sl.make
	it := l.get_new_iterator
	from it.start
	until it.is_off
	loop
	    sl.add_last(it.item.name)
	    it.next
	end
	sl.add_last("Custom")
	preset_lb.put_list(sl)
	preset_list := l
    end

    make is
    local
	b : BUTTON
	c : COMMAND
	l : LABEL
    do
	widget_init

	put_size(200, 200)
	!!b.make("Ok")
	b.put_size(60, 20)
	!COMMAND_ACTIVATE!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b, 30, 175)

	!!b.make("Cancel")
	b.put_size(60, 20)
	!COMMAND_CANCEL!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b, 100, 175)

	!!l.make("Level")
	l.put_size(50, 20)
	add_widget(l, 10, 10)
	!!preset_lb.make
	!COMMAND_PRESET_CHANGE!c.make(Current)
	preset_lb.put_command(c, preset_lb.signal_change)
	preset_lb.put_size(70, 16)
	add_widget(preset_lb, 70, 10)

	!!l.make("Width")
	l.put_size(50, 20)
	add_widget(l, 10, 30)
	!!width_tb.make
	!COMMAND_CUSTOM_CHANGE!c.make(Current)
	width_tb.put_command(c, width_tb.signal_change)
	width_tb.put_size(40, 16)
	add_widget(width_tb, 70, 30)

	!!l.make("Height")
	l.put_size(50, 20)
	add_widget(l, 10, 50)
	!!height_tb.make
	!COMMAND_CUSTOM_CHANGE!c.make(Current)
	height_tb.put_command(c, height_tb.signal_change)
	height_tb.put_size(40, 16)
	add_widget(height_tb, 70, 50)

	!!l.make("Wrap")
	l.put_size(50, 20)
	add_widget(l, 10, 70)
	!!wrap_cb.make
	!COMMAND_CUSTOM_CHANGE!c.make(Current)
	wrap_cb.put_command(c, wrap_cb.signal_change)
	wrap_cb.put_size(12, 12)
	add_widget(wrap_cb, 75, 75)
    end

    custom_change is
    do
	preset := Void
	preset_lb.put_string("Custom")
    end

    preset_change is
    local
	p : PRESET
    do
--TODO: see if list_i = list.upper
	if preset_lb.string.is_equal("Custom") then
	    put_info(Void, custom)
	else
	    p := get_preset(preset_lb.string)
	    put_info(p, p.setting)
	end
    end

--TODO: repeated code; make new PRESET_TABLE class
    get_preset(s : STRING) : PRESET is
    local
	it : ITERATOR[PRESET]
    do
	it := preset_list.get_new_iterator
	from it.start
	until it.is_off
	loop
	    if it.item.name.is_equal(s) then
		Result := it.item
	    end
	    it.next
	end
    end

    put_info(p : PRESET; s : SETTING) is
    do
	preset := p
	if p = Void then
	    preset_lb.put_string("Custom")
	else
	    preset_lb.put_string(p.name)
	end
	wrap_cb.put_value(s.wrap)
	width_tb.put_string(s.width.to_string)
	height_tb.put_string(s.height.to_string)
    end

    update_setting is
    local
	s : STRING
	i : INTEGER
    do
	if preset = Void then
	    setting := custom
	    setting.put_wrap(wrap_cb.value)

	    s := width_tb.string
	    if s.is_integer then
		i := setting.clip_width(s.to_integer)
		setting.put_width(i)
	    end

	    s := height_tb.string
	    if s.is_integer then
		i := setting.clip_height(s.to_integer)
		setting.put_height(i)
	    end
	else
	    setting := preset.setting
	end
    end
end
