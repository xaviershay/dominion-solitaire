require 'dominion/card'

module Dominion
  # Methods to populate the initial board.
  #
  # Requires an accessor +cards+ in
  # the containing class to contain an array of all the loaded cards
  module Board
    include Dominion::Card

    DEFAULT_CARDS = [:copper, :silver, :gold, :estate, :duchy, :provence, :curse]
    DEFAULT_AMOUNT = 8
    AMOUNTS = {
      :copper => 60,
      :silver => 40,
      :gold   => 30
    }

    def board
      @board ||= begin
        (card_set & cards.keys).map {|x|
          card_array(x, AMOUNTS[x] || DEFAULT_AMOUNT)
        }
      end
    end

    def card_set
      DEFAULT_CARDS + randomize(cards.keys - DEFAULT_CARDS)[0..9]
    end
  end
end
