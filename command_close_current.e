class COMMAND_CLOSE_CURRENT
inherit COMMAND
creation make
feature
    main : NETWALK

    make(m : NETWALK) is
    do
	main := m
    end

    execute is
    do
	main.close_current_window
    end
end
