require 'spec_helper'

describe_card :moneylender do
  it_should_behave_like 'an action card'

  describe 'when playing' do
    it 'allows me to trash a copper to +3 gold' do
      hand cards(:copper, 1)

      playing_card do
        input 'y'
      end
      game.should_not have_prompt

      hand.should_not have_cards(cards(:copper, 1))
      trash.should have_cards(cards(:copper, 1))
    end
    
    it 'does not trash a copper by default' do
      hand cards(:copper, 1)

      playing_card

      game.should_not have_prompt

      hand.should have_cards(cards(:copper, 1))
      trash.should_not have_cards(cards(:copper, 1))
    end

    it 'does not prompt if I have no copper in hand' do
      playing_card do
        game.should_not have_prompt
      end
    end
  end
end
