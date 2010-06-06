CARDS[:chapel] = {
  :type        => :action,
  :cost        => 2,
  :description => 'Trash <= 4 cards',
  :behaviour   => lambda {|game, card|
    trash_count = 0
    max_trash = 4
    game.engine.prompt = {
      :prompt => "trash (#{max_trash - trash_count} left)?",
      :autocomplete => Dominion::Input::Autocomplete.cards_in_hand(game),
      :accept => lambda {|input|
        if input
          game.trash_card(game.player, input)
          trash_count += 1
          game.engine.prompt[:prompt] = "trash (#{max_trash - trash_count} left)?",

          if trash_count >= max_trash
            game.engine.prompt = nil
          end
        else
          game.engine.prompt = nil
        end
      }
    }
  }
}
