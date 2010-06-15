require 'spec_helper'

describe_card :witch do
  it_should_behave_like 'an action card'
  it_should_behave_like 'an attack card'

  it 'should give a curse card to each other player' do
    # Unimplemented - not for solitaire, though should decrement curses on board
  end
end
