class NEWHS_WINDOW
inherit
    WINDOW
creation make
feature
    name_tb : TEXTBOX

    make is
    local
	b : BUTTON
	c : COMMAND
	l : LABEL
    do
	widget_init

	put_size(200, 100)
	!!b.make("Ok")
	b.put_size(60, 20)
	!COMMAND_ACTIVATE!c.make(Current)
	b.put_command(c, b.signal_activate)
	add_widget(b, 30, 75)

	!!l.make("New high score!")
	l.put_size(100, 20)
	add_widget(l, 10, 5)

	!!l.make("Name")
	l.put_size(50, 20)
	add_widget(l, 10, 30)
	!!name_tb.make
	name_tb.put_size(120, 16)
	add_widget(name_tb, 60, 30)
	name_tb.put_command(c, name_tb.signal_activate)
    end
end
