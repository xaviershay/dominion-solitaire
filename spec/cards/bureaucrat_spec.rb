require 'spec_helper'

describe_card :bureaucrat, :needs_cards => [:silver] do
  it_should_behave_like 'an action card'
  it_should_behave_like 'an attack card'

  describe 'when played' do
    it 'puts a silver card on the top of my deck' do
      deck []

      playing_card

      deck.should have_cards(cards(:silver, 1))
    end

    it 'does not gain a silver if no more are left in the pile' do
      pending
    end

    it 'forces each other player to reveal a victory card and put it on top of their deck' do
      # Unimplemented - not relevant for solitaire
    end
  end
end
