class CHECKBOX
inherit
    WIDGET
creation make
feature
    value : BOOLEAN

    put_value(b : BOOLEAN) is
    do
	value := b
    end

    make is
    do
	widget_init
    end

    process_event(e : EVENT) is
    do
	if e.type = sdl_mousebuttondown then
	    value := not value
	end
	raise_signal(signal_change)
    end

    update is
    do
	fill_rect(0, 0, width, height, white)
	if value then
	    fill_rect(1, 1, width - 2, height - 2, green)
	else
	    fill_rect(1, 1, width - 2, height - 2, darkgreen)
	end
    end
end
