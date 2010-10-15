Dominion::CARDS[:remodel] = {
  :type        => :action,
  :cost        => 4,
  :description => 'Trash a card, gain a card cost up to +2T more',
  :behaviour   => lambda {|game, card|
    Dominion::Input.accept_cards(
      :strategy => Dominion::Input::Autocomplete.cards_in_hand,
      :prompt   => lambda {|game, card| "trash card?" },
      :min      => 1,
      :max      => 1,
      :after    => lambda {|game, inputs|
        unless inputs.empty?
          trashed_card = game.player[:hand].detect(&by_name(inputs[0]))
          game.move_card(trashed_card, game.player[:hand], game.player[:trash])

          Dominion::Input.accept_cards(
            :strategy => Dominion::Input::Autocomplete.cards(&costing_lte(trashed_card[:cost] + 2)),
            :prompt   => lambda {|game, card| "gain card <= #{trashed_card[:cost] + 2}T?" },
            :min      => 1,
            :max      => 1,
            :each     => lambda {|game, input|
              game.gain_card(game.board, game.player, input) 
            }
          )[game, card]
        end
      }
    )[game, card]
  }
}
