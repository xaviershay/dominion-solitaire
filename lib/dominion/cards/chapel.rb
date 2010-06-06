CARDS[:chapel] = {
  :type        => :action,
  :cost        => 2,
  :description => 'Trash <= 4 cards',
  :behaviour   => Dominion::Input.accept_cards(
    :strategy => Dominion::Input::Autocomplete.cards_in_hand,
    :prompt   => lambda {|game, inputs| "trash (%i left)?" % (4 - inputs.length) },
    :each     => lambda {|game, input| game.trash_card(game.player, input) },
    :max      => 4
  )
}
