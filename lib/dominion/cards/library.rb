Dominion::CARDS[:library] = {
  :type        => :action,
  :cost        => 5,
  :description => 'Draw to 7 cards, discard actions as they are drawn',
  :behaviour   => lambda {|game, card|
    player = game.player
    revealed = []

    non_action = lambda {
      revealed.reject {|x| [*x[:type]].include?(:action) }
    }
    while (player[:hand] + non_action[]).length < 7 && !(player[:deck] + player[:discard]).empty?
      game.reveal_card(player).tap do |c|
        revealed << c if c
      end
    end

    game.engine.prompt = {
      :prompt       => "Press enter to continue",
      :autocomplete => lambda {|input| nil },
      :accept       => lambda {|input|
        game.engine.prompt = nil

        non_action[].each do |t|
          game.move_card(t, player[:revealed], player[:hand])
          revealed.delete_at(revealed.index(t))
        end

        revealed.each do |c|
          game.move_card(c, player[:revealed], player[:discard])
        end
      }
    }
  }
}
