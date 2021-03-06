Dominion::CARDS[:mine] = {
  :type        => :action,
  :cost        => 4,
  :description => 'Trash a T, gain a T costing up to +3T more',
  :behaviour   => lambda {|game, card|
    Dominion::Input.accept_cards(
      :strategy => Dominion::Input::Autocomplete.cards(&by_type(:treasure)),
      :prompt   => lambda {|game, card| "trash treasure?" },
      :min      => 1,
      :max      => 1,
      :after    => lambda {|game, inputs|
        unless inputs.empty?
          trashed_card = game.player[:hand].detect(&by_name(inputs[0]))
          game.trash_card(game.player, inputs[0])

          Dominion::Input.accept_cards(
            :strategy => Dominion::Input::Autocomplete.cards(&(
              by_type(:treasure) & costing_lte(trashed_card[:cost] + 3)
            )),
            :prompt   => lambda {|game, card| "gain treasure <= #{trashed_card[:cost] + 3}T?" },
            :min      => 1,
            :max      => 1,
            :each     => lambda {|game, input|
              if card = game.gain_card(game.board, game.player, input)
                game.move_card(card, game.player[:discard], game.player[:hand])
              end
            }
          )[game, card]
        end
      }
    )[game, card]
  }
}

