require 'spec_helper'

describe_card :cellar  do
  describe 'when I discard 0 cards' do
    before do
      deck cards(:copper, 1)

      playing_card(subject)
    end

    it 'does not draw any cards' do
      game.should_not have_prompt
      hand.should     be_empty
      deck.should     have_cards(cards(:copper, 1))
    end
  end

  describe 'when I discard 4 cards' do
    before do
      deck cards(:copper, 4)
      hand cards(:estate, 4)

      playing_card(subject) do
        4.times { input 'estate' }
      end
    end

    it 'draws 4 cards' do
      game.should_not have_prompt
      hand.should     have_cards(cards(:copper, 4))
      deck.should     be_empty
    end
  end
end
