class COMMAND_NEWHS_OK
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
	main.newhs_ok
    end
end
