module Dominion
  # Methods to deal with cards.
  #
  # Requires an accessor +cards+ in the containing class to contain an array
  # of all the loaded cards.
  module Card
    def type?(card, type)
      [*card[:type]].include?(type)
    end

    def by_type(type)
      lambda {|x| type?(x, type) }
    end

    def in_hand
      lambda {|x| player[:hand].include?(x) }
    end
 
    def match_card(*keys)
      lambda {|x| keys.include? x[:key] }
    end

    def card(key)
      cards[key] || raise("No card #{key}")
    end

    def card_array(key, number)
      [card(key)] * number
    end
  end
end
