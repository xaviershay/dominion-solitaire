module Dominion; module UI; end; end;
class Dominion::UI::NCurses
  include FFI::NCurses

  attr_accessor :prompt, :input_buffer, :card_active

  def initialize
    self.prompt = nil
    self.input_buffer = ''

    initscr
    start_color
    noecho

    # set up colour pairs
    #             Background       Foreground
    init_pair(0,  Colour::BLACK,   Colour::BLACK)
    init_pair(1,  Colour::RED,     Colour::BLACK)
    init_pair(2,  Colour::GREEN,   Colour::BLACK)
    init_pair(3,  Colour::YELLOW,  Colour::BLACK)
    init_pair(4,  Colour::BLUE,    Colour::BLACK)
    init_pair(5,  Colour::MAGENTA, Colour::BLACK)
    init_pair(6,  Colour::CYAN,    Colour::BLACK)
    init_pair(7,  Colour::WHITE,   Colour::BLACK)

    init_pair(8,  Colour::BLACK,   Colour::BLACK)
    init_pair(9,  Colour::BLACK,   Colour::RED)
    init_pair(10, Colour::BLACK,   Colour::GREEN)
    init_pair(11, Colour::BLACK,   Colour::YELLOW)
    init_pair(12, Colour::BLACK,   Colour::BLUE)
    init_pair(13, Colour::BLACK,   Colour::MAGENTA)
    init_pair(14, Colour::BLACK,   Colour::CYAN)
    init_pair(15, Colour::BLACK,   Colour::WHITE)
  end

  def step(ctx)
    ch = wgetch(ctx[:input_window])

    if prompt
      case ch
      when 10
        prompt[:accept][prompt[:autocomplete][input_buffer]]
        self.input_buffer = ''
      when 127
        self.input_buffer = input_buffer[0..-2]
      else
        self.input_buffer += ch.chr
      end
    end
  end

  def finalize
    endwin
  end

  def draw(game, ctx = {})
    ctx[:windows] ||= {}
    curs_set 0
    refresh
   
    drawn = [{
      :coords => [14, 80, 0, 0],
      :title  => 'Board',
      :draw   => lambda do |window, game|
        bold_with_color = lambda do |color, text|
          color_index = {
            :white        => 0,
            :yellow       => 3,
            :blue         => 4,
            :red          => 1,
            :cyan_back    => 14,
            :green_back   => 10,
            :magenta_back => 13,
            :yellow_back  => 11
          }[color] || raise("Unknown color: #{color}")
          wattr_set window, A_BOLD, color_index, nil

          wprintw(window, text.to_s)
        end
        print_with_color = lambda do |color, text|
          color_index = {
            :white        => 0,
            :yellow       => 3,
            :blue         => 4,
            :red          => 1,
            :cyan_back    => 14,
            :green_back   => 10,
            :magenta_back => 13,
            :yellow_back  => 11
          }[color] || raise("Unknown color: #{color}")
          wattr_set window, A_NORMAL, color_index, nil

          wprintw(window, text.to_s)
        end

        type_char = {
          :treasure => 'T',
          :action   => 'A',
          :victory  => 'V'
        }

        max_name_length = game.board.map {|pile| pile[0][:name].length }.max
        
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

          print_with_color[:white, ' '] if i > 0
          print_with_color[:yellow, card[:cost]]
          print_with_color[:red,    type_char[card[:type]]]
          print_with_color[:blue,   pile.size]
          print_with_color[:white,  " %s" % card[:name]]
        end

        print_with_color[:white, "\n"]

        body.each do |pile|
          card = pile.first

          print_with_color[:white, ' ']
          print_with_color[:yellow, card[:cost]]
          print_with_color[:red,    type_char[card[:type]]]
          print_with_color[:blue,   '%-2i' % pile.size]
          if card_active?(card)
            bold_with_color[:white,  " %-#{max_name_length}s " % card[:name]]
          else
            print_with_color[:white,  " %-#{max_name_length}s " % card[:name]]
          end

          print_with_color[:cyan_back,    card[:cards] || ' ']
          print_with_color[:green_back,   card[:actions] || ' ']
          print_with_color[:magenta_back, card[:buys] || ' ']
          print_with_color[:yellow_back,  card[:gold] || ' ']

          print_with_color[:white,  " %-#{max_name_length}s\n" % card[:description]]
        end
      end
    }, {
      :title => "Your Turn (%i Action, %i Buy, %i Treasure, %i Deck)" % [
        game.player[:actions],
        game.player[:buys],
        game.treasure(game.player),
        game.player[:deck].length
      ],
      :coords => [10, 80, 14, 0],
      :draw => lambda do |window, game|
        bold_with_color = lambda do |color, text|
          color_index = {
            :white        => 0,
            :yellow       => 3,
            :blue         => 4,
            :red          => 1,
            :cyan_back    => 14,
            :green_back   => 10,
            :magenta_back => 13,
            :yellow_back  => 11
          }[color] || raise("Unknown color: #{color}")
          wattr_set window, A_BOLD, color_index, nil

          wprintw(window, text.to_s)
        end
        print_with_color = lambda do |color, text|
          color_index = {
            :white        => 0,
            :yellow       => 3,
            :blue         => 4,
            :red          => 1,
            :cyan_back    => 14,
            :green_back   => 10,
            :magenta_back => 13,
            :yellow_back  => 11
          }[color] || raise("Unknown color: #{color}")
          wattr_set window, A_NORMAL, color_index, nil

          wprintw(window, text.to_s)
        end
        
        print_with_color[:white, "Hand: "]
        game.player[:hand].each_with_index do |card, index|
          suffix = index == game.player[:hand].length - 1 ? '' : ', '
          if card_active?(card)
            bold_with_color[:white, card[:name] + suffix]
          else
            print_with_color[:white, card[:name] + suffix]
          end
        end
        print_with_color[:white, "\n"]
        print_with_color[:white, "Played: %s\n" % game.player[:played].map {|x| x[:name] }.join(", ")]

      end
    }, {
      :coords => [1, 80, 24, 0],
      :border => false,
      :draw => lambda do |window, game|
        print_with_color = lambda do |color, text|
          color_index = {
            :white        => 7,
            :yellow       => 3,
            :blue         => 4,
            :red          => 1,
            :cyan_back    => 14,
            :green_back   => 10,
            :magenta_back => 13,
            :yellow_back  => 11
          }[color] || raise("Unknown color: #{color}")
          wattr_set window, A_NORMAL, color_index, nil

          wprintw(window, text.to_s)
        end

        if prompt
          #print_with_color[:yellow_back, "%-80s" % ""]

          suggest = prompt[:autocomplete][input_buffer].to_s

          print_with_color[:yellow_back, "%s %s" % [
            prompt[:prompt],
            input_buffer]]

          fill = suggest[input_buffer.length..-1]

          if fill && fill.length > 0
            print_with_color[:red, "%s" % fill]
          end
        else
          print_with_color[:green_back, "%-80s" % " "]
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

  def card_active?(card)
    (self.card_active || lambda { false }).call(card)
  end
end
