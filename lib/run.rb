$LOAD_PATH.unshift(File.dirname(__FILE__))

def log(message)
  @log ||= File.open('debug.log', 'a')
  @log.puts message
  @log.flush
end

require 'dominion/game'

game = Dominion::Game.new

if ARGV[0]
  board = File.open(ARGV[0]).read.lines.reject {|x| x[0] == '#'[0] }.map {|x| x.chomp.downcase.tr(' ', '_').to_sym }
  board += game.default_cards
  game.load_cards(*board)
else
  game.load_all_cards
end
game.run
