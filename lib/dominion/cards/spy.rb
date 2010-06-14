Dominion::CARDS[:spy] = {
  :type        => [:action, :attack],
  :cost        => 4,
  :cards       => 1,
  :actions     => 1,
  :description => 'All reveal top card of deck, you discard or put back',
  :behaviour   => lambda {|game, card|
    card = game.reveal_card(game.player)

    game.engine.prompt = {
      :prompt       => "Discard #{card[:name]} (y/N)?",
      :autocomplete => Dominion::Input::Autocomplete.boolean[game],
      :accept       => lambda {|input|
        if input == 'Y'
          game.move_card(card, game.player[:revealed], game.player[:discard])
        else
          game.move_card(card, game.player[:revealed], game.player[:deck])
        end

        game.engine.prompt = nil
      }
    } if card
  }
}
