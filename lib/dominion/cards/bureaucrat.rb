Dominion::CARDS[:bureaucrat] = {
  :cost        => 4,
  :type        => [:action, :attack],
  :description => "Gain 1 silver to deck, others put V from hand to deck",
  :behaviour   => lambda {|game, card|
    if card = game.gain_card(game.board, game.player, :silver)
      game.move_card(card, game.player[:discard], game.player[:deck])
    end
  }
}
