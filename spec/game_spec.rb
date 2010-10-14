require 'spec_helper'

describe Dominion::Game do
  subject do
    game_with_cards(:copper)
  end

  describe '#step' do
    it 'does not blow up' do
      subject.step
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
