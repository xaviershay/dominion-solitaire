require 'spec_helper'

describe_card :spy do
  it_should_behave_like 'an action card'
  it_should_behave_like 'an attack card'

  describe 'when played' do
    it 'reveals top card and allows to discard' do
      deck cards(:estate, 1)

      playing_card do
        input 'Y'
      end

      deck.should    have_cards([])
      discard.should have_cards(cards(:estate, 1))
    end

    it 'reveals top card and allows to put back' do
      deck cards(:estate, 1)

      playing_card do
        input 'N'
      end

      discard.should have_cards([])
      deck.should    have_cards(cards(:estate, 1))
    end

    it 'should do nothing if no cards in deck/discard' do
      deck []

      playing_card
    end
  end
end
