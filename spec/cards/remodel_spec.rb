require 'spec_helper'

describe_card :remodel, :needs_cards => [:silver, :gold] do
  it_should_behave_like 'an action card'
  
  describe 'when playing' do
    it 'allows me to trash an estate for a silver' do
      hand cards(:estate, 1)

      playing_card do
        input 'estate'
        input 'silver'
      end

      hand.should    have_cards([])
      trash.should   have_cards(cards(:estate, 1))
      discard.should have_cards(cards(:silver, 1))
    end

    it 'does not allow me to trash a silver for a gold' do
      hand cards(:silver, 1)

      playing_card do
        input 'silver'
        input 'gold'
      end

      game.should    have_prompt
      hand.should    have_cards([])
      trash.should   have_cards(cards(:silver, 1))
      discard.should have_cards([])
    end
  end
end
