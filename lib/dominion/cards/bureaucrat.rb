Dominion::CARDS[:bureaucrat] = {
  :cost        => 4,
  :type        => [:action, :attack],
  :description => "Gain 1 silver to top of deck, others put victory card to top of deck",
  :behaviour   => lambda {|game, card|
    if card = game.gain_card(game.board, game.player, :silver)
      game.move_card(card, game.player[:discard], game.player[:deck])
    end
  }
}
