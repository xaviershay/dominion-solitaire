module Dominion
  module Card
    def type?(card, type)
      [*card[:type]].include?(type)
    end
 
    def match_card(*keys)
      lambda {|x| keys.include? x[:key] }
    end
  end
end
