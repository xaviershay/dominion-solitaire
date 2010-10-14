module Dominion
  module Util
    def add_defaults_to_card(name, values)
      values = values.dup
      values[:key]  = name
      values[:name] = name.to_s.tr('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }

      if [*values[:type]].include?(:action)
        existing = values[:behaviour]
        values[:behaviour] = lambda do |game, card|
          game.player[:actions] += card[:actions].to_i
          game.player[:buys]    += card[:buys].to_i
          game.player[:gold]    += card[:gold].to_i
          card[:cards].to_i.times do
            draw_card(game.player)
          end
          existing[game, card] if existing
        end
      end
      values
    end

    def generate_names!(cards)
      cards.each do |key, values|
        add_defaults_to_card(key, values)
      end
    end

    def randomize(array)
      array.sort_by { rand }
    end

    def print_board(board)
      board.each do |pile|
        puts "$%i: %i x %s" % [
          pile.first[:cost],
          pile.length,
          pile.first[:name]]
      end
    end

    def print_player(player)
      puts "Hand: %s" % player[:hand].map {|x|
        x[:name]
      }.join(", ")
    end
  end
end
