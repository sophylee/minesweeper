class Board
  def initialize(row = 9, column = 9)
    @grid = Array.new(row) { Array.new(column, "_") }
  end

  def show
    @grid.each do |row|
      p row
    end
  end

  def update(location, mark)
    x,y = location
    @grid[x][y] = mark
  end

  def add_tiles_to_grid

  end


end

class Tile
  attr_accessor :bomb, :location, :board, :flagged, :revealed

  def initialize(bomb, location, board, flagged = false, revealed = false)
    @neighbors = get_neighbors
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
    self.revealed = true
    @board.update(self.location, self.bomb_count)

    self.neighbors.each do |neighbor|
      if neighbor.bomb_count == 0
        neighbor.reveal
      else
      end
    end
  end

  def flag
    @board.update(self.location, "F")
  end

  def get_neighbors
    neighbors = []
    @board.grid.each do |tile|
      tile_x, tile_y = tile.location
      self_x, self_y = self.location
      if self_x - tile_x == 1 || self_x - tile_x == 0 || self_x - tile_x == -1
        if self_y - tile_y == 1 || self_y - tile_y == 0 || self_y - tile_y == -1
          neighbors << tile
        end
      end
    end

    neighbors
  end

  def bomb_count
    bomb_count = 0

    @neighbors.each do |neighbor|
      bomb_count +=1 if neighbor.bomb?
    end

    bomb_count
  end
end

new_board = Board.new
new_board.show