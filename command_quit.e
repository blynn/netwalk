class COMMAND_QUIT
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
	main.quit
    end
end
