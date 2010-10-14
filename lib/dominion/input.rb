module Dominion
  class Input
    def self.accept_cards(opts)
      lambda {|game, card|
        inputs = []

        game.prompt = {
          :prompt       => opts[:prompt][game, inputs],
          :autocomplete => opts[:strategy][game],
          :accept       => lambda {|input|
            if input
              inputs << input
              existing = game.prompt
              game.prompt = nil
              opts[:each].call(game, input) if opts[:each]


              unless game.prompt || (opts[:max] && inputs.length >= opts[:max])
                game.prompt = existing
                game.prompt[:prompt] = opts[:prompt].call(game, inputs)
              end
            else
              if !opts[:min] || inputs.length >= opts[:min]
                game.prompt = nil
              end
            end

            if opts[:after] && game.prompt.nil?
              opts[:after].call(game, inputs)
            end
          }
        }
      }
    end

    class Autocomplete
      def self.cards(&match_func)
        lambda {|game| {
          :card_active => lambda {|card|
            match_func.call(card)
          },
          :strategy => lambda {|input|
            suggest = input.length == 0 ? nil : game.board.map(&:first).detect {|x|
              match_func.call(x) && x[:name] =~ /^#{input}/i
            }
            suggest ? suggest[:name] : nil
          }
        }}
      end

      def self.cards_on_board(match_func = lambda {|x| true })
        lambda {|game|
          {
            :card_active => lambda {|card| match_func[card] },
            :strategy    => lambda {|input|
              suggest = input.length == 0 ? nil : game.board.detect {|x|
                x[0][:name] =~ /^#{input}/i && match_func[x[0]]
              }
              suggest ? suggest[0][:name] : nil
            }
          }
        }
      end

      def self.cards_in_hand(match_func = lambda {|x| true })
        lambda {|game|
          {
            :card_active => lambda {|card| match_func[card] },
            :strategy    => lambda {|input|
              suggest = input.length == 0 ? nil : game.player[:hand].detect {|x|
                x[:name] =~ /^#{input}/i && match_func[x]
              }
              suggest ? suggest[:name] : nil
            }
          }
        }
      end

      def self.boolean
        lambda {|game|
          {
            :card_active => lambda {|card| false },
            :strategy    => lambda {|input|
              %w(Y N).detect {|x| x == input.upcase } || nil
            }
          }
        }
      end
    end
  end
end
