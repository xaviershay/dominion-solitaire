$LOAD_PATH.unshift(File.dirname(__FILE__))

def log(message)
  @log ||= File.open('debug.log', 'a')
  @log.puts message
  @log.flush
end

require 'dominion/game'

game = Dominion::Game.new
game.load_all_cards
game.run
