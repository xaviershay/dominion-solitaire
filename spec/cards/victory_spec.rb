require 'spec_helper'

[:estate, :duchy, :provence, :curse].each do |name|
  describe_card name do
    it_should_behave_like 'a victory card'
  end
end
