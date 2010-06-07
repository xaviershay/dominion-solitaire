require 'spec_helper'

[:copper, :silver, :gold].each do |name|
  describe_card name do
    it_should_behave_like 'a treasure card'
  end
end
