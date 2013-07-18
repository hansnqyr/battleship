class HansKreugerPlayer 
    
    require 'colored'

    HIT_BONUS = 11
    PARITY = 0
    PROBABILITY = 1
    DELAY = 1.000

    def name
        "@hanskreuger"
    end

    def new_game
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
        targets = []
        target_x = 0
        target_y = 0

        10.times do |x|
            10.times do |y|
                if grid[x][y] > highest || highest == 0
                    highest = grid[x][y]
                    targets = []
                    targets << [x, y]
                elsif grid[x][y] == highest
                    targets << [x, y]
                end
            end
        end
        index = Random.rand(targets.length )
        target = targets[index]
       
        puts heatmap(grid)

        sleep DELAY
        return target.reverse # your next shot co-ordinates
    end
    
    def heatmap(grid)
        top = grid.flatten.uniq.max
        text = String.new
        10.times do |x|
            10.times do |y|
                score = grid[x][y]
                square = grid[x][y].to_s.rjust(top.to_s.length,"0") + ","
                case
                when score > top * 0.8
                    text += square.magenta
                when score > top * 0.6
                    text += square.red
                when score > top * 0.4
                    text += square.yellow
                when score > top * 0.2
                    text += square.cyan
                when score > 0
                    text += square.white
                else
                    text += square.black
                end
            end
            text += "\n"
        end
        return text
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
