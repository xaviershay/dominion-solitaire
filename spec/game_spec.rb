require 'spec_helper'

describe Dominion::Game do
  subject do
    game_with_cards(:copper, :smithy, :chancellor)
  end

  describe '#step' do
    it 'does not blow up' do
      subject.step
    end

    describe 'when no prompt' do
      describe 'when actions available' do
        describe 'when autoplay actions in hand' do
        end

        describe 'when actions in hand' do
          before do
            hand cards(:copper, 1) + cards(:smithy, 1)

            subject.step
          end

          it { should have_prompt_with_autocomplete :actions_in_hand }
        end
      end

      describe 'when no actions left and buys available' do
        before do
          player[:actions] = 0

          subject.step
        end

        it { should have_prompt_with_autocomplete :buyable_cards }
      end

      describe 'with no actions and no buys' do
        it 'cleans up and progresses to the next turn' do
        end
      end
    end
  end

  describe '#card_active?' do
    let(:check_card) { card(:copper) }

    describe 'when no card_active proc is supplied' do
      before do
        subject.card_active = nil
      end

      specify do
        subject.card_active?(check_card).should be_false
      end
    end

    describe 'when a card_active proc is supplied' do
      before do
        subject.card_active = lambda {|card| card[:key] }
      end

      specify do
        subject.card_active?(check_card).should == check_card[:key]
      end
    end
  end
end
