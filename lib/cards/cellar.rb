Game.instance.add_card(:cellar) do
  {
    :type => :action,
    :cost => 2,
    :actions => 1,
    :description => 'Discard X cards, draw X cards',
    :behaviour => lambda {|player, card|
      discard_count = 0
      engine.prompt = {
        :prompt => "discard (#{discard_count} so far)?",
        :autocomplete => lambda {|input|
          suggest = input.length == 0 ? nil : player[:hand].detect {|x|
            x[:name] =~ /^#{input}/i
          }
          suggest ? suggest[:name] : nil
        },
        :accept => lambda {|input|
          if input
            discard_card(player, input)
            discard_count += 1
            engine.prompt[:prompt] = "discard (#{discard_count} so far)?"
          else
            engine.prompt = nil
          end

          unless engine.prompt
            discard_count.times { draw_card(player) }
          end
        }
      }
    }
  }
end
