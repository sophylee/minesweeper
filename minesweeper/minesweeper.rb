require "colorize"
require "YAML"
require 'io/console'

class Board
  attr_accessor :grid

  def initialize(game, row = 10, column = 25)
    @grid = Array.new(row) { Array.new(column, "_") }
    @row = row
    @col = column
    @game = game
    add_tiles_to_grid
    plant_bombs
  end

  def shown_grid
    system "clear"
    user_grid = Array.new(@row) { Array.new(@col, "_") }
    @grid.each_with_index do |row, r_idx|
      row.each_with_index do |t, c_idx|
        if t.flagged?
          user_grid[r_idx][c_idx] = "F".red.on_white
        elsif t.bomb? && !t.flagged?
          user_grid[r_idx][c_idx] = "_".white.on_white
        elsif t.revealed?
          case t.bomb_count
          when 0
            user_grid[r_idx][c_idx] = " ".on_light_white
          when 1
            user_grid[r_idx][c_idx] = "1".blue.on_light_white
          when 2
            user_grid[r_idx][c_idx] = "2".green.on_light_white
          when 3
            user_grid[r_idx][c_idx] = "3".red.on_light_white
          else
            user_grid[r_idx][c_idx] = t.bomb_count.to_s.red.on_light_white
          end
        else
          user_grid[r_idx][c_idx] = "_".white.on_white
        end
      end
    end
    current_value = user_grid[@game.cursor_x][@game.cursor_y]
    user_grid[@game.cursor_x][@game.cursor_y] = current_value.on_red

    user_grid
  end

  def print_grid
    shown_grid.each_with_index do |row, i|
      puts row.map(&:to_s).join("")
    end
  end

  def add_tiles_to_grid
    @grid.each_with_index do |tile, row|
      tile.each_with_index do |t, col|
        @grid[row][col] = Tile.new(false, [row, col], self)
      end
    end
  end

  def won?
    grid.flatten.all? do |tile|
      tile.revealed? || tile.bomb?
    end
  end

  def plant_bombs
    bombs = 0
    number_bombs = 25
    until bombs == number_bombs
      rand_x = rand(@row)
      rand_y = rand(@col)
      unless @grid[rand_x][rand_y].bomb?
        @grid[rand_x][rand_y].bomb = true
        bombs += 1
      end
    end
  end
end

class Tile
  attr_accessor :bomb, :location, :board, :flagged, :revealed

  def initialize(bomb, location, board, flagged = false, revealed = false)
    @bomb, @location, @board, @flagged, @revealed = bomb, location, board, flagged, revealed
  end

  def bomb?
    self.bomb == true
  end

  def flagged?
    self.flagged == true
  end

  def revealed?
    self.revealed == true
  end

  def reveal
    return if self.revealed?
    self.revealed = true
    # @board.update(self.location, self.bomb_count)

    self.get_neighbors.each do |neighbor|
      if self.bomb_count == 0
        neighbor.reveal unless neighbor.bomb?
      end
    end
  end

  def flag
    self.flagged = true
  end

  def unflag
    self.flagged = false
  end

  def get_neighbors
    neighbors = []
    @board.grid.each do |row|
      row.each do |tile|
        tile_x, tile_y = tile.location
        self_x, self_y = self.location
        if self_x - tile_x == 1 || self_x - tile_x == 0 || self_x - tile_x == -1
          if self_y - tile_y == 1 || self_y - tile_y == 0 || self_y - tile_y == -1
            neighbors << tile
          end
        end
      end
    end

    neighbors
  end

  def bomb_count
    bomb_count = 0

    get_neighbors.each do |neighbor|
      bomb_count +=1 if neighbor.bomb?
    end

    bomb_count
  end
end

class Game
  attr_accessor :cursor_x, :cursor_y

  def initialize
    @board = Board.new(self)
    @cursor_location = [0,0]
    @cursor_x, @cursor_y = @cursor_location
    @time_start = Time.now
  end

  def play
    valid_keys = ["w", "a", "s", "d", "q", "f"," ", "`"]
    input = nil
    @board.print_grid
    puts "Use WASD keys to move. f to flag, space to play space, ` to save"
    until @board.won?
      until valid_keys.include?(input)
        input = STDIN.getch
      end
      if input == "`"
        return self.save
      elsif input == "q"
        puts "quitting"
        return
      elsif input == "w" && @cursor_x > 0
        @cursor_x -= 1
      elsif input == "a" && @cursor_y > 0
        @cursor_y -= 1
      elsif input == "s" && @cursor_x < @board.grid.count - 1
        @cursor_x += 1
      elsif input == "d" && @cursor_y < @board.grid.first.count - 1
        @cursor_y += 1
      elsif input == "f"
        if @board.grid[@cursor_x][@cursor_y].flagged?
          @board.grid[@cursor_x][@cursor_y].unflag
        else
          @board.grid[@cursor_x][@cursor_y].flag
        end
      elsif input == " "
        if @board.grid[@cursor_x][@cursor_y].bomb?
          puts "you suck, loser! BOOM!"
          return
        else
          @board.grid[@cursor_x][@cursor_y].reveal
        end
      end
      input = nil
      @board.print_grid
      puts "Use WASD keys to move. f to flag, space to play space, ` to save"
    end
    @board.print_grid
    @time_won = Time.now
    @total_time = @time_won - @time_start
    puts "You WON!!!!!!! It took you #{@total_time.floor} seconds."
    puts "Leaderboard: "
    current_leaderboard = File.read("leaderboard")
    game_file = YAML::load(current_leaderboard)
    puts game_file
  end

  def update_leaderboard
    puts "What's your name champ?"
    name = gets.chomp
    File.new("leaderboard") do |f|
      f.puts ("#{name}: #{@total_time}").to_yaml
    end

  end

  # def play
#     until @board.won?
#
#       @board.print_grid
#
#       puts "HEY you want to save? (y/n)"
#       save_response = gets.chomp.downcase
#       if save_response == 'y'
#         return self.save
#       end
#
#       puts "Enter row number"
#       row = gets.chomp.to_i
#       puts "Enter col number"
#       col = gets.chomp.to_i
#       puts "Flag? (y/n)"
#       flag = gets.chomp.downcase
#
#       if @board.grid[row][col].bomb? && flag != "y"
#         puts "you suck"
#         return
#       elsif flag == 'y'
#         puts "flagging #{[row, col]}"
#         @board.grid[row][col].flag
#       else
#         puts "revealing #{[row, col]}"
#         @board.grid[row][col].reveal
#       end
#     end
#
#     puts "YOU WIN!!!"
#   end

  def save
    saved_game = self.to_yaml
  end

end

class Leaderboard
  def initialize
    File.new("leaderboard")
  end
end

# new_board = Board.new
# new_board.print_grid

puts "HEY you want to load a saved game? (y/n)"
load_response = gets.chomp.downcase
if load_response == 'y'
  puts "name of load file"
  load_file = gets.chomp
  contents = File.read(load_file)
  game_file = YAML::load(contents)
  save_file = game_file.play
else
  new_game = Game.new
  save_file = new_game.play
end

if save_file
  puts "Name your game:"
  save_name = gets.chomp
  puts "saving file #{save_name}"
  File.open(save_name, "w") do |f|
    f.puts save_file
  end
end