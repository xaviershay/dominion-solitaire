require 'ffi-ncurses'
require 'dominion/engine'
require 'dominion/ui/ncurses/window'
require 'dominion/ui/ncurses/board_window'
require 'dominion/ui/ncurses/play_area_window'
require 'dominion/ui/ncurses/input_window'

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

  def draw(game, ctx = {})
    ctx[:windows] ||= {}
    curs_set 0
    refresh
   
    drawn = [
      BoardWindow.new(game),
      PlayAreaWindow.new(game),
      InputWindow.new(game, input_buffer)
    ].map do |window|
      c = window.coords
      board_frame = (ctx[:windows][[:outer] + c] ||= newwin(*c))

      if window.border
        board = (ctx[:windows][[:inner] + c] ||= newwin(c[0] - 2, c[1] - 2, c[2] + 1, c[3] + 1))

        window.window = board
        window.draw

        wattr_set board_frame, A_NORMAL, 7, nil
        box(board_frame, c[2], c[3])
        wmove(board_frame, 0, 2)
        waddstr(board_frame, "| #{window.title} |")
        wrefresh(board_frame)
        wrefresh(board)
        {
          :frame => board_frame,
          :inner => board
        }
      else
        window.window = board_frame
        window.draw
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
