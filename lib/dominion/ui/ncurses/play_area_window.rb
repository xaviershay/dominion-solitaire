module Dominion::UI::NCurses
  class PlayAreaWindow < Window
    def initialize(*args)
      super
    end

    def coords
      [10, 80, 14, 0]
    end

    def title
      "Turn %i (%i Action, %i Buy, %i Treasure, %i Discard, %i Deck)" % [
        game.turn,
        game.player[:actions],
        game.player[:buys],
        game.treasure(game.player),
        game.player[:discard].length,
        game.player[:deck].length
      ]
    end

    def draw
      print( :white, "Hand: " )
      line_length = 6
      game.player[:hand].each_with_index do |card, index|
        suffix = index == game.player[:hand].length - 1 ? '' : ', '
        print( :white, card[:name] + suffix, game.card_active?(card) )
        line_length += (card[:name] + suffix).length
      end

      # TODO: print ' ' doesn't work :(
      print( :white, " " * (77 - line_length) ) if line_length < 76
      print( :white, "\n" )

      played = "Played: %s" % game.player[:played].map {|x| x[:name] }.join(", ")
      print( :white, played )
      print( :white, " " * (77 - played.length) ) if played.length < 76
      print( :white, "\n" )

      unless game.player[:revealed].empty?
        revealed = "Revealed: %s\n" % game.player[:revealed].map {|x| x[:name] }.join(", ")
        print( :white, revealed )
        print( :white, " " * (77 - revealed.length) )
      end
    end
  end
end
