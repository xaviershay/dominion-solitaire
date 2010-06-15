require 'spec_helper'

describe_card :library do
  it_should_behave_like 'an action card'
  
  describe 'when played' do
    it 'reveals cards until hand + revealed non-action cards = 7, then discards actions, and puts non-action into hand' do
      deck cards(:library, 3) + cards(:estate, 10)
      hand cards(:estate, 3) + cards(:library, 3)

      playing_card

      hand.should have_cards(cards(:estate, 4) + cards(:library, 3))
      discard.should have_cards(cards(:library, 3))
    end
  end
end
