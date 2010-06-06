CARDS[:cellar] = {
  :type => :action,
  :cost => 2,
  :actions => 1,
  :description => 'Discard X cards, draw X cards',
  :behaviour => lambda {|game, card|
    discard_count = 0
    game.engine.prompt = {
      :prompt => "discard (#{discard_count} so far)?",
      :autocomplete => lambda {|input|
        suggest = input.length == 0 ? nil : game.player[:hand].detect {|x|
          x[:name] =~ /^#{input}/i
        }
        suggest ? suggest[:name] : nil
      },
      :accept => lambda {|input|
        if input
          game.discard_card(game.player, input)
          discard_count += 1
          game.engine.prompt[:prompt] = "discard (#{discard_count} so far)?"
        else
          game.engine.prompt = nil
        end

        unless game.engine.prompt
          discard_count.times { game.draw_card(game.player) }
        end
      }
    }
  }
}
