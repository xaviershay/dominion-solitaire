$LOAD_PATH.unshift(File.dirname(__FILE__))

def log(message)
  @log ||= File.open('debug.log', 'a')
  @log.puts message
  @log.flush
end

require 'dominion/game'
require 'dominion/ui/ncurses/engine'

game = Dominion::Game.new

if ARGV[0]
  board = File.open(ARGV[0]).read.lines.reject {|x| x[0] == '#'[0] }.map {|x| x.chomp.downcase.tr(' ', '_').to_sym }
  board += Dominion::Game::DEFAULT_CARDS
  game.load_cards(*board)
else
  game.load_all_cards
end
game.engine = Dominion::UI::NCurses::Engine.new
game.run
