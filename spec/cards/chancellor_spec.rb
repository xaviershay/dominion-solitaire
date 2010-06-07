require 'spec_helper'

describe_card :chancellor do
  it_should_behave_like 'an action card'

  describe 'when playing' do
    it 'allows me to discard my deck' do
      deck cards(:copper, 1)

      playing_card do
        input 'y'
      end
      game.should_not have_prompt

      deck.should have_cards([])
      discard.should have_cards(cards(:copper, 1))
    end
    
    it 'does not discard my deck by default' do
      deck cards(:copper, 1)

      playing_card

      game.should_not have_prompt
      discard.should have_cards([])
      deck.should have_cards(cards(:copper, 1))
    end
  end
end
