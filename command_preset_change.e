class COMMAND_PRESET_CHANGE
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
	main.preset_change
    end
end
