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
      def self.name_starts_with(input)
        lambda {|x| x[:name] =~ /^#{input}/i }
      end

      def self.in_stack(stack)
        lambda {|card| stack.include?(card) }
      end

      def self.autocomplete(source, match_func)
        {
          :card_active => match_func & in_stack(source),
          :strategy    => lambda {|input|
            suggest = input.length == 0 ? nil : source.detect(&(
              match_func & name_starts_with(input)
            ))
            suggest ? suggest[:name] : nil
          }
        }
      end

      def self.cards(match_func = nil, &block)
        if block
          raise("Can't specify block and lambda") if match_func
          match_func = block
        elsif match_func.nil?
          match_func = lambda {|x| true }
        end

        lambda {|game|
          autocomplete(game.board.map(&:first), match_func)
        }
      end

      def self.cards_in_hand(match_func = lambda {|x| true })
        lambda {|game|
          autocomplete(game.player[:hand], match_func)
        }
      end

      def self.boolean
        lambda {|game| {
            :card_active => lambda {|card| false },
            :strategy    => lambda {|input|
              %w(Y N).detect {|x| x == input.upcase } || nil
            }
        }}
      end
    end
  end
end
