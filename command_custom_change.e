class COMMAND_CUSTOM_CHANGE
inherit COMMAND
creation make
feature
    main : OPTIONS_WINDOW

    make(m : like main) is
    do
	main := m
    end

    execute is
    do
	main.custom_change
    end
end
