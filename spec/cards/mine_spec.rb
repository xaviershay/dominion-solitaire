require 'spec_helper'

describe_card :mine, :needs_cards => [:silver, :gold] do
  it_should_behave_like 'an action card'
  
  describe 'when playing' do
    it 'allows me to trash a copper for a silver' do
      hand cards(:copper, 1)

      playing_card do
        input 'copper'
        input 'silver'
      end

      trash.should  have_cards(cards(:copper, 1))
      hand.should   have_cards(cards(:silver, 1))
    end

    it 'allows me to trash a silver for a gold' do
      hand cards(:silver, 1)

      playing_card do
        input 'silver'
        input 'gold'
      end

      trash.should have_cards(cards(:silver, 1))
      hand.should  have_cards(cards(:gold, 1))

    end

    it 'does not allow me to trash a copper for a gold' do
      hand cards(:copper, 1)

      playing_card do
        input 'copper'
        input 'gold'
      end

      game.should    have_prompt
      hand.should    have_cards([])
      trash.should   have_cards(cards(:copper, 1))
    end
  end
end

