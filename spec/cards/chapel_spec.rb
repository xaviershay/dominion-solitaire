require 'spec_helper'

describe_card :chapel do
  it_should_behave_like 'an action card'

  describe 'when I input 4 cards' do
    before do
      hand cards(:copper, 5)

      playing_card(subject) do
        4.times { 
          game.should have_prompt_with_autocomplete(:cards_in_hand)
          input 'copper' 
        }
        game.should_not have_prompt # Max 4 cards
      end
    end

    it 'trashes those cards' do
      hand.should  have_cards(cards(:copper, 1))
      trash.should have_cards(cards(:copper, 4))
    end
  end
end
