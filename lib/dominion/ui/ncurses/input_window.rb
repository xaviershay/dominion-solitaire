module Dominion::UI::NCurses
  class InputWindow < Window
    attr_accessor :input_buffer

    def initialize(game, input_buffer)
      super(game)
      self.input_buffer = input_buffer
    end

    def coords
      [1, 80, 24, 0]
    end

    def border
      false
    end

    def draw
      if game.prompt
        suggest = game.prompt[:autocomplete][:strategy][input_buffer].to_s

        print( game.prompt[:color] || :yellow_back, "%s %s" % [
          game.prompt[:prompt],
          input_buffer
        ])

        fill = suggest[input_buffer.length..-1]

        if fill && fill.length > 0
          print( :red, "%s" % fill )
        end
      else
        print( :green_back, "%-80s" % " " )
      end
    end
  end
end
