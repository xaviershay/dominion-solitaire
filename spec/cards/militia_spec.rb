require 'spec_helper'

describe_card :militia do
  it_should_behave_like 'an action card'
  it_should_behave_like 'an attack card'
  
  describe 'when played' do
    it 'forces other players to discard to 3 cards' do
      # Unimplemented - not relevant for solitaire
    end
  end
end
