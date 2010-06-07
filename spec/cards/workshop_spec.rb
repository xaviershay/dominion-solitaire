require 'spec_helper'

describe_card :workshop, :needs_card => [:gold] do
  it_should_behave_like 'an action card'

  describe 'when playing' do
    it 'allows me to gain a card costing <= 4' do
      playing_card do
        input 'gold'   # No
        input 'estate' # THAT'S HOW I ROLL
      end

      discard.should have_cards(cards(:estate, 1))
    end
  end
end
