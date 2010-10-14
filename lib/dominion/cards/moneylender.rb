Dominion::CARDS[:moneylender] = {
  :type        => :action,
  :cost        => 4,
  :description => 'Trash a copper, +3T',
  :behaviour => lambda {|game, card|
    if game.player[:hand].detect {|x| x[:key] == :copper }
      game.prompt = {
        :prompt       => "Trash a copper (N/y)?",
        :autocomplete => Dominion::Input::Autocomplete.boolean[game],
        :accept       => lambda {|input|
          if input == 'Y'
            game.move_card(:copper, game.player[:hand], game.player[:trash]) 
            game.player[:gold] += 3
          end

          game.prompt = nil
        }
      }
    end
  }
}
