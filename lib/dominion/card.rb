module Dominion
  # Methods to deal with cards.
  #
  # Requires an accessor +cards+ in the containing class to contain an array
  # of all the loaded cards.
  module Card
    def in_hand
      lambda {|x| player[:hand].include?(x) }
    end
 
    def card(key)
      cards[key] || raise("No card #{key}")
    end

    def card_array(key, number)
      [card(key)] * number
    end
  end

  # Generic matchers that are mixed into the global namespace
  module CardMatchers
    def type?(card, type)
      [*card[:type]].include?(type)
    end

    def by_type(type)
      lambda {|x| type?(x, type) }
    end

    def match_card(*keys)
      by_key *keys
    end

    def by_key(*keys)
      lambda {|x| keys.include? x[:key] }
    end

    def by_name(name)
      lambda {|x| x[:name] == name }
    end

    def costing_lte(cost)
      lambda {|x| x[:cost] <= cost }
    end

  end
end

include Dominion::CardMatchers
