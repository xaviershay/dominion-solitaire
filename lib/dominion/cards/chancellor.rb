Dominion::CARDS[:chancellor] = {
  :type => :action,
  :cost => 3,
  :gold => 2,
  :description => 'Optionally discard your deck',
  :behaviour => lambda {|game, card|
    game.prompt = {
      :prompt       => "Discard your deck (y/N)?",
      :autocomplete => Dominion::Input::Autocomplete.boolean[game],
      :accept       => lambda {|input|
        if input == 'Y'
          game.player[:discard] += game.player[:deck]
          game.player[:deck] = []
        end

        game.prompt = nil
      }
    }
  }
}
