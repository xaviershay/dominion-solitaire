module Dominion
  module Card
    def type?(card, type)
      [*card[:type]].include?(type)
    end
  end
end
