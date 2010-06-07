Dominion::CARDS[:chancellor] = {
  :type => :action,
  :cost => 3,
  :gold => 2,
  :behaviour => lambda {|game, card|
    game.engine.prompt = {
      :prompt       => "Discard your deck (y/N)?",
      :autocomplete => Dominion::Input::Autocomplete.boolean[game],
      :accept       => lambda {|input|
        if input == 'Y'
          game.player[:discard] += game.player[:deck]
          game.player[:deck] = []
        end

        game.engine.prompt = nil
      }
    }
  }
}
