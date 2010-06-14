require 'spec_helper'

describe_card :throne_room, :needs_cards => [:woodcutter] do
  it_should_behave_like 'an action card'
  
  describe 'when played' do
    it 'allows me to play an action card in my hand twice' do
      hand cards(:woodcutter, 1) 

      playing_card do
        input 'Woodcutter'
      end

      player[:buys].should == 3
      player[:gold].should == 4

      hand.should   have_cards([])
      played.should have_cards(cards(:throne_room, 1) + cards(:woodcutter, 1))
    end

    it 'does nothing when no action cards in hand' do
      playing_card
    end

    it 'forces me to choose an action' do
      hand cards(:woodcutter, 1)
      playing_card
      game.should have_prompt
    end
  end
end
