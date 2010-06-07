require 'spec_helper'

describe_card :adventurer do
  it_should_behave_like 'an action card'

  describe 'when played' do
    it 'reveals cards until 2 treasures are revealed, then puts them both in hand and discards the rest' do
      deck cards(:estate, 1) + cards(:copper, 2) 

      playing_card(subject)

      hand.should    have_cards(cards(:copper, 2))
      discard.should have_cards(cards(:estate, 1))
    end

    it 'aborts if 2 treasures cannot be found' do
    end
  end
end
