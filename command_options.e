class COMMAND_OPTIONS
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
	main.options
    end
end
