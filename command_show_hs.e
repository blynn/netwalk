class COMMAND_SHOW_HS
inherit COMMAND
creation make
feature
    main : NETWALK

    make(m : like main) is
    do
	main := m
    end

    execute is
    do
	main.show_hs
    end
end
