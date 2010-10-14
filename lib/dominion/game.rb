require 'dominion/ui'
require 'dominion/util'
require 'dominion/player'
require 'dominion/input'

module Dominion
  class Game
    include Dominion::Util
    include Dominion::Player

    attr_accessor :board, :cards, :player, :turn

    def initialize
      @cards = {}
      @turn  = 1

      self.engine = Dominion::UI::NCurses.new
    end

    def player
      @player ||= {
        :actions => 1,
        :buys => 1,
        :gold => 0,
        :hand    => [],
        :discard => [],
        :trash   => [],
        :played  => [],
        :revealed => [],
        :bought  => [],
        :discarded => [],
        :trashed => [],
        :deck => randomize(
           [cards[:estate]] * 3 +
           [cards[:copper]] * 7
        ).compact
      }
    end

    def default_cards
      [:copper, :silver, :gold, :estate, :duchy, :provence, :curse]
    end

    def board
      @board ||= begin
        (default_cards + randomize(@cards.keys - default_cards)[0..9]).map {|x|
          if @cards.has_key?(x) 
            [card(x)] * ({
              :copper => 60,
              :silver => 40,
              :gold   => 30
            }[x] || 8)
          else
            nil
          end
        }.compact
      end
#         [card(:copper)] * 60,
#         [card(:silver)] * 40,
#         [card(:gold)] * 30,
    end

    def card(key)
      cards[key] || raise("No card #{key}")
    end

    def add_card(key, values)
      key = key.to_sym
      @cards[key] = add_defaults_to_card(key, values)
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

    def test
      print_board(board)

      require 'pp'
      5.times { draw_card(player) }
      print_player(player)
      play_card(player, :cellar)
      pp player
    end
    
    attr_accessor :engine
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
