class BUTTON
inherit
    WIDGET
creation make
feature
    string : STRING

    make(s : STRING) is
    do
	widget_init
	!!string.copy(s)
	!!img.make
	update_image
    end

    process_event(e : EVENT) is
    do
	if e.type = sdl_mousebuttondown then
	    raise_signal(signal_activate)
	end
    end

    update is
    do
	fill_rect(0, 0, width, height, darkgreen)
	fill_rect(1, 1, width - 2, height - 2, black)
	if string.count > 0 then
	    blit(img, 2, 2)
	end
    end

    img : IMAGE

    update_image is
    do
	if img.is_connected then
	    img.free
	end
	if string.count > 0 then
	    img.render_string(string, font, white)
	end
    end
end
