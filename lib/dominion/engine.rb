module Dominion
  class Engine
    attr_accessor :prompt

    def setup
      self.prompt = nil
      self.input_buffer = ''
    end

    def draw(game, ctx = {})
    end

    def step(ctx)
    end

    def finalize
    end
  end
end
