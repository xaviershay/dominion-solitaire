describe 'an action card', :shared => true do
  it 'has a type of :action' do
    subject[:type] == :action
  end

  describe 'when played' do
    before { playing_card(subject) }

    it "increments the player actions by it's action count" do
      player[:actions].should == subject[:actions].to_i + 1
    end

    it "increments the player buys by it's buy count" do
      player[:buys].should == subject[:buys].to_i + 1
    end

    it "increments the player gold by it's gold count" do
      player[:gold].should == subject[:gold].to_i
    end

    it "draws cards equal to it's card count" do
      player[:hand].size.should == subject[:cards].to_i
    end
  end
end
