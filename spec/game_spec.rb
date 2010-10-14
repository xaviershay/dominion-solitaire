require 'spec_helper'

describe Dominion::Game do
  describe 'the initial board' do
    before do
      subject.load_cards(:copper, :silver, :gold, :provence)
    end

    it 'contains 60 copper' do
      subject.board.detect {|x| x[0][:key] == :copper }.length.should == 60
    end

    it 'contains 40 silver' do
      subject.board.detect {|x| x[0][:key] == :silver }.length.should == 40
    end

    it 'contains 30 gold' do
      subject.board.detect {|x| x[0][:key] == :gold }.length.should == 30
    end

    it 'contains 8 provences' do
      subject.board.detect {|x| x[0][:key] == :provence }.length.should == 8
    end

    it 'contains none of a card if it has not been loaded' do
      subject.board.detect {|x| x[0][:key] == :duchy }.should be_nil
    end
  end
end
