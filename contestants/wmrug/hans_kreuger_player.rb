class HansKreugerPlayer 
    HIT_BONUS = 25
    PROBABILITY = 1
    DELAY = 0

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
                if grid[x][y] >= highest && state[x][y] == :unknown
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
                range = (0-size)..(0+size)
                range.each do |start|
                    miss = false
                    hit = 0
                    ship = []
                    size.times do |length|
                        if (0...9).include?(x + start + length)
                            ship << state[x + start + length][y]
                        else
                            ship << :miss
                        end
                    end
                    if !(ship.include? :miss)
                        position = 0
                        ship.each do | value |
                            case value
                            when :unknown
                                grid[x + start + position][y] += PROBABILITY
                            when :hit
                                grid[x + start + position - 1][y] += HIT_BONUS unless x + start + position - 1 < 0
                                grid[x + start + position + 1][y] += HIT_BONUS unless x + start + position + 1 > 9
                            end
                            position += 1
                        end
                    end
                end
            end
        end
        10.times do |x|
            10.times do |y|
                range = (0-size)..(0+size)
                range.each do |start|
                    miss = false
                    hit = 0
                    ship = []
                    size.times do |length|
                        if (0...9).include?(y + start + length)
                            ship << state[x][y + start + length]
                        else
                            ship << :miss
                        end
                    end
                    if !(ship.include? :miss)
                        position = 0
                        ship.each do | value |
                            case value
                            when :unknown
                                grid[x][y + start + position] += PROBABILITY
                            when :hit
                                grid[x][y + start + position - 1] += HIT_BONUS unless y + start + position - 1 < 0
                                grid[x][y + start + position + 1] += HIT_BONUS unless y + start + position + 1 > 9
                            end
                            position += 1
                        end
                    end
                end
            end
        end
        return grid
    end
end
