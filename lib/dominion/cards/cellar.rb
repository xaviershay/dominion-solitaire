CARDS[:cellar] = {
  :type        => :action,
  :cost        => 2,
  :actions     => 1,
  :description => 'Discard X cards, draw X cards',
  :behaviour   => Dominion::Input.accept_cards(
    :strategy => Dominion::Input::Autocomplete.cards_in_hand,
    :prompt   => lambda {|game, inputs| "discard (%i so far)? " % inputs.length },
    :each     => lambda {|game, input| game.discard_card(game.player, input) },
    :after    => lambda {|game, inputs|
      inputs.length.times { game.draw_card(game.player) }
    }
  )
}
