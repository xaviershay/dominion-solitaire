require 'spec_helper'

describe Dominion::Game do
  describe 'the initial board' do
    DB = Dominion::Board

    subject do
      Dominion::Game.new.tap {|game|
        game.load_cards(default_card, defined_card)
      }.board
    end

    include Dominion::Board

    let(:default_card)  { (DB::DEFAULT_CARDS - DB::AMOUNTS.keys)[0] }
    let(:defined_card)  { (DB::DEFAULT_CARDS & DB::AMOUNTS.keys)[0] }
    let(:unloaded_card) { (DB::DEFAULT_CARDS - DB::AMOUNTS.keys)[1] }

    it { should have_stack(defined_card, DB::AMOUNTS[defined_card]) }
    it { should have_stack(default_card, DB::DEFAULT_AMOUNT) }
    it { should_not have_stack(unloaded_card) }
  end
end
