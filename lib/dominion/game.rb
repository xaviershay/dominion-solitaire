require 'dominion/engine'
require 'dominion/util'
require 'dominion/player'
require 'dominion/board'
require 'dominion/input'
require 'dominion/card'
require 'dominion/autoplay'
require 'core_ext/proc'

module Dominion
  # The main game logic. See #run.
  class Game
    include Dominion::Card
    include Dominion::Util
    include Dominion::Player
    include Dominion::Board
    include Dominion::Autoplay

    attr_accessor :engine, :cards, :turn, :prompt

    def initialize
      self.cards = {}
      self.turn  = 1
      self.engine = Dominion::Engine.new
    end

    def step
      skip = false

      if self.prompt.nil?
        if player[:actions] > 0 && player[:hand].detect(&by_type(:action))
          return if autoplay!

          self.prompt = {
            :prompt      => "action (#{player[:actions]} left)?",
            :autocomplete => Input::Autocomplete.cards(&(by_type(:action) & in_hand))[self],
            :color  => :green_back,
            :accept => accept(
              :accept  => lambda {|input| play_card(player, input) },
              :decline => lambda {|input| player[:actions] = 0 }
            )
          }
        elsif player[:buys] > 0
          self.prompt = {
            :prompt      => "buy (#{treasure(player)}/#{player[:buys]} left)?",
            :autocomplete => Input::Autocomplete.cards {|card|
              card[:cost] <= treasure(player)
            }[self],
            :color  => :magenta_back,
            :accept => accept(
              :accept  => lambda {|input| buy_card(board, player, input) },
              :decline => lambda {|input| player[:buys] = 0 }
            )
          }
        else
          cleanup(board, player)
          skip = true
          @turn += 1
        end
      end

      unless skip
        ctx = engine.draw(self)
        engine.step(self, ctx)
      end
    end

    # The main game loop. Will not return, use CTRL+C to exit.
    def run
      cleanup(board, player)
      engine.setup

      while true
        step
      end
    ensure
      engine.finalize if engine
    end

    # An active card is one that can be interacted with. They are generally
    # highlighted in the UI.
    #
    #   card - a hash describing a card
    def card_active?(card)
      self.prompt && self.prompt[:autocomplete][:card_active][card]
    end

    def treasure(player)
      player[:gold] + player[:hand].select {|x| 
        type?(x, :treasure)
      }.map {|x|
        x[:gold] 
      }.inject(0) {|a, b| 
        a + b 
      }
    end

    def wrap_behaviour(&block)
      if prompt
        # Add an after function to the prompt, rather than running the code now
        existing = prompt[:accept]
        prompt[:accept] = lambda {|input|
          existing[input]

          wrap_behaviour { block.call }
        }
      else
        block.call
      end
    end

    def load_all_cards
      load_cards(*Dir[File.dirname(__FILE__) + '/cards/*.rb'].map {|x|
        File.basename(x).split('.')[0..-2].join(".")
      })
    end

    def load_cards(*args)
      args.map(&:to_sym).each do |c|
        require File.dirname(__FILE__) + "/cards/#{c}"
        add_card(c, CARDS[c])
      end
    end

    def self.instance
      @instance ||= new
    end

    private
    
    def accept(config)
      lambda {|input|
        self.prompt = nil
        if input
          config[:accept][input]
        else
          config[:decline][input]
        end
      }
    end

    def add_card(key, values)
      key = key.to_sym
      cards[key] = add_defaults_to_card(key, values)
    end

  end
  CARDS = {}
end
