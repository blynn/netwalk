class LABEL
inherit
    WIDGET
creation make
feature
    string : STRING

    put_string(s : STRING) is
    do
	!!string.copy(s)
	update_image
    end

    make(s : STRING) is
    do
	widget_init
	!!string.copy(s)
	!!img.make
	img.new_dummy
	update_image
    end

    process_event(e : EVENT) is
    do
    end

    update is
    do
	fill_rect(1, 1, width - 2, height - 2, black)
	if string.count > 0 then
	    blit(img, 2, 2)
	end
    end

    img : IMAGE

    update_image is
    require
	img.is_connected
    do
	img.free
	if string.count > 0 then
	    img.render_string(string, font, white)
	end
    ensure
	img.is_connected
    end
end
