CARDS[:chapel] = {
  :type        => :action,
  :cost        => 2,
  :description => 'Trash <= 4 cards',
  :behaviour   => lambda {|game, card|
    trash_count = 0
    max_trash = 4
    game.engine.prompt = {
      :prompt => "trash (#{max_trash - trash_count} left)?",
      :autocomplete => lambda {|input|
        suggest = input.length == 0 ? nil : game.player[:hand].detect {|x|
          x[:name] =~ /^#{input}/i
        }
        suggest ? suggest[:name] : nil
      },
      :accept => lambda {|input|
        if input
          game.trash_card(game.player, input)
          trash_count += 1
          game.engine.prompt[:prompt] = "trash (#{max_trash - trash_count} left)?",

          if trash_count >= max_trash
            game.engine.prompt = nil
          end
        else
          game.engine.prompt = nil
        end
      }
    }
  }
}
