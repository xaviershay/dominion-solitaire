require 'ffi-ncurses'
require 'dominion/engine'

module Dominion; module UI; end; end;
class Dominion::UI::NCurses < Dominion::Engine
  include FFI::NCurses
  include Colour

  attr_accessor :input_buffer

  def initialize
    self.input_buffer = ''
  end

  def setup
    super

    initscr
    start_color
    noecho

    [BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE].each_with_index do |color, index|
      init_pair(index,     color, BLACK)
      init_pair(index + 8, BLACK, color)
    end
  end

  BACKSPACE = 127
  ENTER     = 10

  def step(game, ctx)
    ch = wgetch(ctx[:input_window])

    if game.prompt
      case ch
      when ENTER
        autocompleted = game.prompt[:autocomplete][:strategy][input_buffer]
        if !(autocompleted == nil && input_buffer.length > 0)
          game.prompt[:accept][autocompleted]
        end
        self.input_buffer = ''
      when BACKSPACE
        self.input_buffer = input_buffer[0..-2]
      else
        if ch.chr =~ /^[a-z ]+$/i
          self.input_buffer += ch.chr 
        end
      end
    end
  end

  def finalize
    endwin
  end

  def colors
    {
      :white        => 0,
      :yellow       => 3,
      :blue         => 4,
      :red          => 1,
      :cyan_back    => 14,
      :green_back   => 10,
      :magenta_back => 13,
      :yellow_back  => 11
    }
  end

  def bold_with_color(window, game, color, text)
    color_index = colors[color] || raise("Unknown color: #{color}")
    wattr_set window, A_BOLD, color_index, nil

    waddstr(window, text.to_s)
  end

  def print_with_color(window, game, color, text)
    color_index = colors[color] || raise("Unknown color: #{color}")
    wattr_set window, A_NORMAL, color_index, nil

    waddstr(window, text.to_s)
  end

  def draw(game, ctx = {})
    ctx[:windows] ||= {}
    curs_set 0
    refresh
   
    drawn = [{
      :coords => [14, 80, 0, 0],
      :title  => 'Board',
      :draw   => lambda do |window, game|
        bwc = lambda {|color, text| bold_with_color(window, game, color, text)}
        pwc = lambda {|color, text| print_with_color(window, game, color, text)}

        type_char = [
          [:reaction, 'R'],
          [:attack,   'X'],
          [:treasure, 'T'],
          [:victory,  'V'],
          [:action,   'A']
        ]

        max_name_length = game.board.map {|pile| 
          pile[0][:name].length 
        }.max
        
        header, body = game.board.partition {|x|
          [
            :copper,
            :silver,
            :gold,
            :estate,
            :duchy,
            :provence,
            :curse
          ].include?(x.first[:key])
        }

        header.each_with_index do |pile, i|
          card = pile.first

          pwc[:white, ' '] if i > 0
          pwc[:yellow, card[:cost]]
          pwc[:red,    type_char.detect {|x| [*card[:type]].include?(x[0]) }[1]]
          pwc[:blue,   pile.size]
          pwc[:white,  " %s" % card[:name]]
        end
        pwc[:white, "\n"] 
        body.sort_by {|x| [x[0][:cost], x[0][:name]] }.each do |pile|
          card = pile.first

          pwc[:white, ' ']
          pwc[:yellow, card[:cost]]
          pwc[:red,    type_char.detect {|x| [*card[:type]].include?(x[0]) }[1]]
          pwc[:blue,   '%-2i' % pile.size]
          if game.card_active?(card)
            bwc[:white,  " %-#{max_name_length}s " % card[:name]]
          else
            pwc[:white,  " %-#{max_name_length}s " % card[:name]]
          end

          pwc[:cyan_back,    card[:cards] || ' ']
          pwc[:green_back,   card[:actions] || ' ']
          pwc[:magenta_back, card[:buys] || ' ']
          pwc[:yellow_back,  card[:gold] || ' ']

          pwc[:white,  " %-#{max_name_length}s\n" % card[:description]]
        end
      end
    }, {
      :title => "Turn %i (%i Action, %i Buy, %i Treasure, %i Discard, %i Deck)" % [
        game.turn,
        game.player[:actions],
        game.player[:buys],
        game.treasure(game.player),
        game.player[:discard].length,
        game.player[:deck].length
      ],
      :coords => [10, 80, 14, 0],
      :draw => lambda do |window, game|
        bwc = lambda {|color, text| bold_with_color(window, game, color, text)}
        pwc = lambda {|color, text| print_with_color(window, game, color, text)}
        
        pwc[:white, "Hand: "]
        line_length = 6
        game.player[:hand].each_with_index do |card, index|
          suffix = index == game.player[:hand].length - 1 ? '' : ', '
          if game.card_active?(card)
            bwc[:white, card[:name] + suffix]
          else
            pwc[:white, card[:name] + suffix]
          end
          line_length += (card[:name] + suffix).length
        end

        # TODO: print ' ' doesn't work :(
        pwc[:white, " " * (77 - line_length)] if line_length < 76
        pwc[:white, "\n"]
        played = "Played: %s" % game.player[:played].map {|x| x[:name] }.join(", ")
        pwc[:white, played]
        pwc[:white, " " * (77 - played.length)] if played.length < 76
        pwc[:white, "\n"]

        unless game.player[:revealed].empty?
          revealed = "Revealed: %s\n" % game.player[:revealed].map {|x| x[:name] }.join(", ")
          pwc[:white, revealed]
          pwc[:white, " " * (77 - revealed.length)]
        end

      end
    }, {
      :coords => [1, 80, 24, 0],
      :border => false,
      :draw => lambda do |window, game|
        pwc = lambda {|color, text| print_with_color(window, game, color, text)}

        if game.prompt
          suggest = game.prompt[:autocomplete][:strategy][input_buffer].to_s

          pwc[game.prompt[:color] || :yellow_back, "%s %s" % [
            game.prompt[:prompt],
            input_buffer]]

          fill = suggest[input_buffer.length..-1]

          if fill && fill.length > 0
            pwc[:red, "%s" % fill]
          end
        else
          pwc[:green_back, "%-80s" % " "]
        end
      end
    }].map do |window|
      window[:border] = true unless window.has_key?(:border)

      c = window[:coords]
      board_frame = (ctx[:windows][[:outer] + c] ||= newwin(*c))

      if window[:border]
        board = (ctx[:windows][[:inner] + c] ||= newwin(c[0] - 2, c[1] - 2, c[2] + 1, c[3] + 1))

        window[:draw][board, game]

        wattr_set board_frame, A_NORMAL, 7, nil
        box(board_frame, c[2], c[3])
        wmove(board_frame, 0, 2)
        waddstr(board_frame, "| #{window[:title]} |")
        wrefresh(board_frame)
        wrefresh(board)
        {
          :frame => board_frame,
          :inner => board
        }
      else
        window[:draw][board_frame, game]
        wrefresh(board_frame)
        {
          :frame => nil,
          :inner => board_frame
        }
      end
    end

    {:input_window => drawn[0][:inner]}
  end
end
