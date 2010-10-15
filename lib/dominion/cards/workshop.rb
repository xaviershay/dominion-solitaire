Dominion::CARDS[:workshop] = {
  :type        => :action,
  :cost        => 3,
  :description => 'Gain a card costing <= 4',
  :behaviour   => Dominion::Input.accept_cards(
    :strategy => Dominion::Input::Autocomplete.cards {|x| x[:cost] <= 4},
    :prompt   => lambda {|game, inputs| "gain card?" },
    :each     => lambda {|game, input| 
      game.gain_card(game.board, game.player, input) 
    },
    :max      => 1,
    :min      => 1
  )
}
