deferred class COLOR_TABLE
feature
    black : COLOR is
    once
	!!Result.make(0, 0, 0)
    end

    white : COLOR is
    once
	!!Result.make(255, 255, 255)
    end

    darkred : COLOR is
    once
	!!Result.make(127, 0, 0)
    end

    red : COLOR is
    once
	!!Result.make(255, 0, 0)
    end

    cyan : COLOR is
    once
	!!Result.make(0, 255, 255)
    end

    yellow : COLOR is
    once
	!!Result.make(255, 255, 0)
    end

    purple : COLOR is
    once
	!!Result.make(255, 0, 255)
    end

    blue : COLOR is
    once
	!!Result.make(0, 0, 255)
    end

    green : COLOR is
    once
	!!Result.make(0, 255, 0)
    end

    darkpurple : COLOR is
    once
	!!Result.make(127, 0, 127)
    end
end
