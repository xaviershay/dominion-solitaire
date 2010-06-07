require 'spec_helper'

[:woodcutter, :smithy, :festival, :laboratory, :market, :village].each do |c|
  describe_card c do
    it_should_behave_like 'an action card'
  end
end
