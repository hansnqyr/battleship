class HansKreugerPlayer 
    
    require 'colored'

    HIT_BONUS = 11
    PARITY = 0
    PROBABILITY = 1
    DELAY = 0.000

    def name
        # Uniquely identify your player
        "@hanskreuger"
    end

    def new_game
        # return an array of 5 arrays containing
        # [x,y, length, orientation]
        # e.g.
        if true
        [
            [2, 0, 5, :across],
            [4, 9, 4, :across],
            [0, 7, 3, :down],
            [8, 2, 3, :down],
            [5, 5, 2, :down]
        ]
        else
        [
            [0, 0, 5, :across],
            [6, 9, 4, :across],
            [0, 7, 3, :down],
            [9, 0, 3, :down],
            [5, 5, 2, :down]
        ]
        end
    end

    def take_turn(state, ships_remaining)
        # state is the known state of opponents fleet
        # ships_remaining is an array of the remaining opponents ships
        @state = state
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
                
                heat = grid[x][y]
                case 
                when heat > 500
                    heat = heat.to_s.rjust(3,"0").magenta
                when heat > 200
                    heat = heat.to_s.rjust(3,"0").red
                when heat > 100
                    heat = heat.to_s.rjust(3,"0").yellow
                when heat > 50
                    heat = heat.to_s.rjust(3,"0").cyan
                when heat > 0
                    heat = heat.to_s.rjust(3,"0").white
                else
                    heat = heat.to_s.rjust(3,"0").black
                end
                print heat + ","
            end
            print "\n"
        end
        sleep DELAY
        return [target_x,target_y] # your next shot co-ordinates
    end

    def new_grid
        grid = Array.new
        toggle = false
        10.times do |x|
            grid[x] = Array.new
            10.times do |y|
                grid[x][y] = toggle ? 0 : PARITY
                toggle = !toggle
            end
            toggle = !toggle
        end
        return grid
    end

    def hit?(x, y)
        get_state(x, y) == :hit
    end

    def miss?(x, y)
        get_state(x, y) == :miss
    end
    
    def unknown?(x, y)
        get_state(x, y) == :unknown
    end
    
    def get_state(x, y)
        if (0..9).include?(x) && (0..9).include?(y) 
            @state[x][y] 
        else
            :miss
        end
    end

    def check_ship(state, size)
        grid = new_grid
        10.times do |x|
            10.times do |y|
                range = (1-size)..(size-1)
                range.each do |start|
                    ship = []
                    size.times do | position |
                        p_x = x + start + position
                        ship << get_state(p_x, y)
                    end
                    size.times do | part |
                        s_x = x + start + part
                        case ship[part]
                        when :unknown
                            grid[s_x][y] += PROBABILITY + (ship.include?(:hit) ? HIT_BONUS : 0)
                        when :hit
                            grid[s_x][y] = 0
                            grid[s_x - 1][y] += HIT_BONUS if unknown?(s_x - 1, y)  && ! hit?(s_x, y - 1) && ! hit?(s_x, y + 1)
                            grid[s_x + 1][y] += HIT_BONUS if unknown?(s_x + 1, y)  && ! hit?(s_x, y - 1) && ! hit?(s_x, y + 1)
                        when :miss
                            grid[s_x][y] = 0
                        end if (0..9).include?(s_x) 
                    end unless ship.include? :miss
                end
            end
        end
        10.times do |x|
            10.times do |y|
                range = (1-size)..(size-2)
                range.each do |start|
                    ship = []
                    size.times do | position |
                        p_y = y + start +position
                        ship << ( (0..9).include?(p_y) ? state[x][p_y] : :miss )
                    end
                    size.times do | part |
                        s_y = y + start + part
                        case ship[part]
                        when :unknown
                            grid[x][s_y] += PROBABILITY + (ship.include?(:hit) ? HIT_BONUS : 0)
                        when :hit
                            grid[x][s_y] = 0
                            grid[x][s_y - 1] += HIT_BONUS if unknown?(x, s_y - 1)  && ! hit?(x - 1, s_y) && ! hit?(x + 1, s_y )
                            grid[x][s_y + 1] += HIT_BONUS if unknown?(x, s_y + 1)  && ! hit?(x - 1, s_y) && ! hit?(x + 1, s_y )
                        when :hit, :miss
                            grid[x][s_y] = 0
                        end if (0..9).include?(s_y) 
                    end unless ship.include? :miss
                end
            end
        end
        return grid
    end
end
