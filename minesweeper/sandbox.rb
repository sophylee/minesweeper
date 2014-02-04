require 'io/console'
input = nil
until input == "q"
  input = STDIN.getch
  p input
end