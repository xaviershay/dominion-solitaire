require 'spec_helper'

describe_card :cellar  do
  it_should_behave_like 'an action card'

  describe 'when I discard 0 cards' do
    before do
      deck cards(:copper, 1)

      playing_card(subject)
    end

    it 'does not draw any cards' do
      game.should_not have_prompt
      hand.should     be_empty
      deck.should     have_cards(cards(:copper, 1))
    end
  end

  describe 'when I discard X cards' do
    let(:x) { 2 }

    before do
      deck cards(:copper, x)
      hand cards(:estate, x + 1)

      playing_card(subject) do
        x.times {
          game.should have_prompt_with_autocomplete(:cards_in_hand)
          input 'estate'
        }
        game.should have_prompt_with_autocomplete(:cards_in_hand)
      end
    end

    it 'draws X cards' do
      hand.should have_cards(cards(:copper, x) + cards(:estate, 1))
      deck.should be_empty
    end
  end
end
