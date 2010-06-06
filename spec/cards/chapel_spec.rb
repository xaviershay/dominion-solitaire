require 'spec_helper'

describe_card :chapel do
  describe 'when I try to select 5 cards' do
    before do
      hand cards(:copper, 5)

      playing_card(subject) do
        5.times { input 'copper' }
      end
    end

    it 'trashes the first 4' do
      hand.should  have_cards(cards(:copper, 1))
      trash.should have_cards(cards(:copper, 4))
    end
  end
end
