module Dominion
  # Rules to autoplay solitaire matches, for speedier gold fishing
  module Autoplay
    CARDS_TO_AUTOPLAY = [:village, :market, :laboratory]

    def autoplay!
      ret = false

      unless player[:hand].detect(&match_card(:throne_room))
        while to_play = player[:hand].detect(&match_card(*CARDS_TO_AUTOPLAY))
          play_card(player, to_play[:name])
          ret = true
        end
      end

      ret
    end
  end
end
