Game.instance.add_card(:chapel) do
  {
    :type => :action,
    :cost => 2,
    :description => 'Trash <= 4 cards',
    :behaviour => lambda {|player, card|
      trash_count = 0
      max_trash = 4
      engine.prompt = {
        :prompt => "trash (#{max_trash - trash_count} left)?",
        :autocomplete => lambda {|input|
          suggest = input.length == 0 ? nil : player[:hand].detect {|x|
            x[:name] =~ /^#{input}/i
          }
          suggest ? suggest[:name] : nil
        },
        :accept => lambda {|input|
          if input
            trash_card(player, input)
            trash_count += 1
            engine.prompt[:prompt] = "trash (#{max_trash - trash_count} left)?",

            if trash_count >= max_trash
              engine.prompt = nil
            end
          else
            engine.prompt = nil
          end
        }
      }
    }
  }
end
