require 'dominion/ui'
require 'dominion/util'
require 'dominion/player'
require 'dominion/board'
require 'dominion/input'

module Dominion
  class Game
    include Dominion::Util
    include Dominion::Player
    include Dominion::Board

    attr_accessor :engine, :cards, :turn

    def initialize
      self.cards = {}
      self.turn  = 1
      self.engine = Dominion::UI::NCurses.new
    end

    def add_card(key, values)
      key = key.to_sym
      cards[key] = add_defaults_to_card(key, values)
    end

    def treasure(player)
      player[:gold] + player[:hand].select {|x| 
        x[:type] == :treasure 
      }.map {|x|
        raise x.inspect unless x[:gold]
        x[:gold] 
      }.inject(0) {|a, b| 
        a + b 
      }
    end

    def run
      cleanup(board, player)
      engine.setup
      running = true

      while running
        skip = false
        if engine.prompt.nil?
          if player[:actions] > 0 && player[:hand].detect {|x| [*x[:type]].include?(:action) }
            autoplay = [:village, :market, :laboratory]
            unless player[:hand].detect {|x| x[:key] == :throne_room }
              while to_play = player[:hand].detect {|x| autoplay.include?(x[:key]) }
                play_card(player, to_play[:name])
                skip = true
              end
            end

            next if skip

            engine.card_active = lambda {|card| [*card[:type]].include?(:action) && player[:hand].include?(card)}
            engine.prompt = {
              :prompt => "action (#{player[:actions]} left)?",
              :autocomplete => lambda {|input|
                suggest = input.length == 0 ? nil : player[:hand].detect {|x|
                  [*x[:type]].include?(:action) && x[:name] =~ /^#{input}/i
                }
                suggest ? suggest[:name] : nil
              },
              :color  => :green_back,
              :accept => lambda {|input|
                engine.prompt = nil
                if input
                  play_card(player, input)
                else
                  player[:actions] = 0
                end
              }
            }
          elsif player[:buys] > 0 # TODO: option to skip copper buys
            engine.card_active = lambda {|card| 
              card[:cost] <= treasure(player)
            }
            engine.prompt = {
              :prompt => "buy (#{treasure(player)}/#{player[:buys]} left)?",
              :autocomplete => lambda {|input|
                suggest = input.length == 0 ? nil : board.map(&:first).detect {|x|
                  x[:cost] <= treasure(player) && x[:name] =~ /^#{Regexp.escape(input)}/i
                }
                suggest ? suggest[:name] : nil
              },
              :color  => :magenta_back,
              :accept => lambda {|input|
                if input
                  buy_card(board, player, input)
                else
                  player[:buys] = 0
                end
                engine.prompt = nil
              }
            }
          else
            # Run the cleanup phase
            cleanup(board, player)
            skip = true
            @turn += 1
          end
        end

        unless skip
          ctx = engine.draw(self)
          engine.step(ctx)
        end
      end
    ensure
      engine.finalize if engine
    end

    def self.instance
      @instance ||= new
    end

    def wrap_behaviour(&block)
      prompt = engine.prompt

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
  end
  CARDS = {}
end
