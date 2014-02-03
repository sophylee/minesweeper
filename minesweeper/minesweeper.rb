require "colorize"

class Board
  attr_accessor :grid

  def initialize(row = 9, column = 9)
    @grid = Array.new(row) { Array.new(column, "_") }
    @row = row
    @col = column
    add_tiles_to_grid
    plant_bombs
  end

  def shown_grid
    shown_grid = Array.new(@row) { Array.new(@col, "_") }
    @grid.each_with_index do |row, r_idx|
      row.each_with_index do |t, c_idx|
        if t.flagged?
          shown_grid[r_idx][c_idx] = "F".red
        elsif t.bomb? && !t.flagged?
          shown_grid[r_idx][c_idx] = "_".white
        elsif t.revealed?
          shown_grid[r_idx][c_idx] = t.bomb_count.to_s
        else
          shown_grid[r_idx][c_idx] = "_".white
        end
      end
    end
    shown_grid
  end

  def print_grid
    puts "- 0 1 2 3 4 5 6 7 8".blue
    shown_grid.each_with_index do |row, i|
      print "#{i} ".blue
      puts row.map(&:to_s).join(" ")
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
    until bombs == 9
      rand_x = rand(9)
      rand_y = rand(9)
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
  def initialize
    @board = Board.new
  end

  def play
    until @board.won?
      @board.print_grid
      puts "Enter row number"
      row = gets.chomp.to_i
      puts "Enter col number"
      col = gets.chomp.to_i
      puts "Flag? (y/n)"
      flag = gets.chomp.downcase
      if @board.grid[row][col].bomb? && flag != "y"
        puts "you suck"
        return
      elsif flag == 'y'
        puts "flagging #{[row, col]}"
        @board.grid[row][col].flag
      else
        puts "revealing #{[row, col]}"
        @board.grid[row][col].reveal
      end
    end
    puts "YOU WIN!!!"
  end

end

# new_board = Board.new
# new_board.print_grid

new_game = Game.new
new_game.play