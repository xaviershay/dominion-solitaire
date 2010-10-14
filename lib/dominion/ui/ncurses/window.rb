module Dominion::UI::NCurses
  class Window
    include FFI::NCurses

    attr_accessor :window, :game

    def initialize(game)
      self.game = game
    end

    def print(color, text, bold = false)
      color_index = colors[color] || raise("Unknown color: #{color}")
      wattr_set window, bold ? A_BOLD : A_NORMAL, color_index, nil

      waddstr(window, text.to_s)
    end

    def colors
      {
        :white        => 0,
        :yellow       => 3,
        :blue         => 4,
        :red          => 1,
        :cyan_back    => 14,
        :green_back   => 10,
        :magenta_back => 13,
        :yellow_back  => 11
      }
    end

    def border
      true
    end
  end
end
