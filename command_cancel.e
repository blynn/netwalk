class COMMAND_CANCEL
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
	main.raise_signal(main.signal_cancel)
    end
end
