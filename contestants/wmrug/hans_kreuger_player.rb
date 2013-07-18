class HansKreugerPlayer 
    HIT_BONUS = 5
    PROBABILITY = 1
    DELAY = 1

    def name
        # Uniquely identify your player
        "hans"
    end

    def new_game
        # return an array of 5 arrays containing
        # [x,y, length, orientation]
        # e.g.
        [
            [0, 0, 5, :down],
            [4, 4, 4, :across],
            [9, 3, 3, :down],
            [2, 2, 3, :across],
            [9, 7, 2, :down]
        ]
    end

    def take_turn(state, ships_remaining)
        # state is the known state of opponents fleet
        # ships_remaining is an array of the remaining opponents ships

        grid = new_grid
        ships_remaining.each do |ship|
            ship_grid = check_ship(state, ship)
            10.times do |x|
                10.times do |y|
                    grid[x][y] += ship_grid[x][y]
                end
            end
        end

        highest = 0
        target_x = 0
        target_y = 0

        10.times do |x|
            10.times do |y|
                if grid[x][y] > highest && state[x][y] == :unknown
                    target_x = y
                    target_y = x
                    highest = grid[x][y]
                end
            end
        end
        sleep DELAY
        return [target_x,target_y] # your next shot co-ordinates
    end

    def new_grid
        grid = Array.new
        10.times do |x|
            grid[x] = Array.new
            10.times do |y|
                grid[x][y] = 0
            end
        end
        return grid
    end

    def check_ship(state, size)
        grid = new_grid
        10.times do |x|
            10.times do |y|
                size.times do |move|
                    miss = false
                    hit = 0
                    size.times do |length|
                        if x - move + length < 9 && x - move + length > 0
                            case state[x - move + length][y]
                            when :miss
                                miss = true
                            when :hit
                                hit += HIT_BONUS
                            end
                        end
                    end
                    grid[x][y] += ( PROBABILITY + hit ) unless miss
                end
            end
        end
        10.times do |x|
            10.times do |y|
                size.times do |move|
                    miss = false
                    hit = 0
                    size.times do |length|
                        if y - move + length < 9 && y - move + length > 0
                            case state[x][y - move + length]
                            when :miss
                                miss = true
                            when :hit
                                hit += HIT_BONUS
                            end
                        end
                    end
                    grid[x][y] += ( PROBABILITY + hit ) unless miss
                end
            end
        end
        return grid
    end
end
