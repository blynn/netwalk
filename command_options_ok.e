class COMMAND_OPTIONS_OK
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
	main.options_ok
    end
end
