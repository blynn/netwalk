class COMMAND_NEW_GAME
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
	main.new_game
    end
end
