module Dominion
  module Player
    def move_card(card, from, to)
      key = if card.is_a?(Symbol)
        card = from.detect {|x| x[:key] == card } 
      else
        card = from.detect {|x| x[:key] == card[:key] } 
      end

      from.delete_at(from.index(card))
      to.unshift(card)
      card
    end

    def draw_card(player)
      if player[:deck].length == 0
        player[:deck] = randomize(player[:discard])
        player[:discard] = []
      end

      player[:hand] << player[:deck].shift unless player[:deck].empty?
    end

    def reveal_card(player)
      if player[:deck].length == 0
        player[:deck] = randomize(player[:discard])
        player[:discard] = []
      end

      unless player[:deck].empty?
        player[:deck].shift.tap do |c|
          player[:revealed] << c
        end
      end
    end

    def gain_card(board, player, card_name_or_key)
      attr = card_name_or_key.is_a?(Symbol) ? :key : :name
      pile = board.detect {|pile| pile[0][attr] == card_name_or_key }
      pile.shift.tap do |card|
        player[:discard] << card
      end
    end

    def buy_card(board, player, card_name)
      pile = board.detect {|pile| pile[0][:name] == card_name.to_s }
      pile.shift.tap do |card|
        player[:bought] << card.dup
        player[:discard] << card
        player[:gold] -= card[:cost]
        player[:buys] -= 1
      end
    end

    def play_card(player, card_name)
      card = player[:hand].detect {|x| x[:name] == card_name.to_s } 

      player[:hand].delete_at(player[:hand].index(card))
      player[:played] << card
      player[:actions] -= 1

      card[:behaviour][self, card]
    end

    def discard_card(player, card_name)
      card = player[:hand].detect {|x| x[:name].downcase == card_name.to_s.downcase } 

      player[:hand].delete_at(player[:hand].index(card))
      player[:discarded] << card.dup
      player[:discard] << card
    end

    def trash_card(player, card_name)
      card = player[:hand].detect {|x| x[:name] == card_name.to_s } 

      player[:hand].delete_at(player[:hand].index(card))
      player[:trashed] << card
      player[:trash] << card
    end

    def format_cards(cards)
      cards.inject({}) {|a, card|
        a[card[:name]] ||= 0
        a[card[:name]] += 1
        a
      }.map {|name, kount|
        if kount == 1
          name
        else
          "#{name} x #{kount}"
        end
      }.sort.join(", ")
    end

    def cleanup(board, player)
      buffer = ["Turn #{@turn}"]
      buffer << "Hand: #{format_cards(player[:hand])}" unless player[:hand].empty? 
      buffer << "Played: #{format_cards(player[:played])}" unless player[:played].empty? 
      buffer << "Trashed: #{format_cards(player[:trashed])}" unless player[:trashed].empty? 
      buffer << "Discarded: #{format_cards(player[:discarded])}" unless player[:discarded].empty? 
      buffer << "Bought: #{format_cards(player[:bought])}" unless player[:bought].empty? 
      log buffer.join("\n") + "\n\n"
      
      player[:discard] += player[:hand]
      player[:discard] += player[:played]
      player[:hand] = []
      player[:played] = []
      player[:discarded] = []
      player[:trashed] = []
      player[:bought] = []
      5.times { draw_card(player) }
      player[:actions] = 1
      player[:buys]    = 1
      player[:gold]    = 0
    end
  end
end
