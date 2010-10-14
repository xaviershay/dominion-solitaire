require 'spec_helper'
require 'dominion/ui'

describe Dominion::UI::NCurses do
  let(:game) { 
    Struct.new(:prompt).new({
      :autocomplete => {
        :strategy => lambda {|input| 'abcde' }
      }
    }) 
  }

  describe '#step' do
    it 'accepts alphabetic input' do
      mock_input 'a'[0]

      subject.step(game, {})
      subject.input_buffer.should == 'a'
    end

    it 'accepts capital input' do
      mock_input 'A'[0]

      subject.step(game, {})
      subject.input_buffer.should == 'A'
    end

    it 'rejects non-alphabetic input' do
      mock_input '1'[0]

      subject.step(game, {})
      subject.input_buffer.should == ''
    end

    it 'accepts backspace' do
      subject.input_buffer = 'abc'
      mock_input 127

      subject.step(game, {})
      subject.input_buffer.should == 'ab'
    end

    it 'accepts enter and autocompletes input' do
      subject.input_buffer = 'abc'
      mock_input 10

      accepted = nil
      game.prompt[:accept] = lambda {|input|
        accepted = input
      }
      subject.step(game, {})
      subject.input_buffer.should == ''
      accepted.should == 'abcde'
    end

    def mock_input(chr)
      mock(subject).wgetch(nil) { chr }
    end
  end
end
