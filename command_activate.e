class COMMAND_ACTIVATE
inherit COMMAND
creation make
feature
    main : WIDGET

    make(m : like main) is
    do
	main := m
    end

    execute is
    do
	main.raise_signal(main.signal_activate)
    end
end
