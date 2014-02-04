require 'io/console'
input = nil
until input == "q"
  input = STDIN.getch
  p input
end

# def play
#   valid_keys = ["w", "a", "s", "d", "q", " ", "`"]
#   input = nil
#   until @board.won?
#     until valid_keys.include?(input)
#       input = STDIN.getch
#     end
#     if input == "`"
#       return self.save
#     elsif input == "q"
#       return
#     elsif input == "w" && @cursor_location[0] > 0
#       @cursor_location[0] -= 1
#     elsif input == "a" && @cursor_location[1] > 0
#       @cursor_location[0] -= 1
#     elsif input == "s" && @cursor_location[0] < @board.grid.count - 1
#       @cursor_location[0] += 1
#     elsif input == "d" && @cursor_location[0] < @board.grid.first.count - 1
#       @cursor_location[0] += 1
#     end
#   end
#
# end