Dominion::CARDS[:throne_room] = {
  :type        => :action,
  :cost        => 4,
  :description => 'Choose an action in your hand, play it twice',
  :behaviour   => Dominion::Input.accept_cards(
    :strategy => Dominion::Input::Autocomplete.cards_in_hand(lambda {|card| [*card[:type]].include?(:action) }),
    :prompt   => lambda {|game, inputs| "action?" },
    :each     => lambda {|game, input| 
      card = game.player[:hand].detect {|x| x[:name] == input }

      if card
        card[:behaviour][game, card]
        game.wrap_behaviour do
          card[:behaviour][game, card]
        end

        game.move_card(card, game.player[:hand], game.player[:played])
      end
    },
    :max      => 1
  )
}
