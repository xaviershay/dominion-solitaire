$LOAD_PATH.unshift(File.dirname(__FILE__))

def log(message)
  @log ||= File.open('debug.log', 'a')
  @log.puts message
  @log.flush
end

require 'dominion/game'

CARDS = {}

game = Game.instance
game.load_cards(:cellar, :chapel)
game.run
