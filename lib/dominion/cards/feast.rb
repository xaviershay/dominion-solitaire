Dominion::CARDS[:feast] = {
  :type        => :action,
  :cost        => 4,
  :description => 'Trash this, Gain a card costing <= 5',
  :behaviour   => Dominion::Input.accept_cards(
    :strategy => Dominion::Input::Autocomplete.cards_on_board(lambda {|x| x[:cost] <= 5}),
    :prompt   => lambda {|game, inputs| "gain card?" },
    :each     => lambda {|game, input| 
      game.gain_card(game.board, game.player, input) 
    },
    :after => lambda {|game, inputs|
      card = game.player[:played].detect {|x| x[:key] == :feast }
      game.move_card(card, game.player[:played], game.player[:trash])
    },
    :max      => 1,
    :min      => 1
  )
}

