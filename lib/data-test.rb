require 'ffi-ncurses'

module Dominion
  module Util
    def generate_names!(cards)
      cards.each do |key, values|
        values[:key]  = key
        values[:name] = key.to_s
      end
    end

    def randomize(array)
      array.sort_by { rand }
    end

    def print_board(board)
      board.each do |pile|
        puts "$%i: %i x %s" % [
          pile.first[:cost],
          pile.length,
          pile.first[:name]]
      end
    end

    def print_player(player)
      puts "Hand: %s" % player[:hand].map {|x|
        x[:name]
      }.join(", ")
    end
  end

  module Player
    def draw_card(player)
      if player[:deck].length == 0
        player[:deck] = randomize(player[:discard])
        player[:discard] = []
      end

      player[:hand] << player[:deck].shift
    end

    def play_card(player, card_name)
      card = player[:hand].detect {|x| x[:name] == card_name.to_s } 

      player[:hand].delete_at(player[:hand].index(card))
      player[:played] << card

      card[:behaviour][player, card]
    end
  end

  module Input
    def prompt_player_for_card_in_hand(player, opts)
      puts opts[:prompt]
      nil
    end
  end
end


class Game
  include Dominion::Util
  include Dominion::Player
  include Dominion::Input

  attr_accessor :board, :cards, :player

  def initialize
    @cards = generate_names!({
      :estate => {
        :type => :victory,
        :cost => 2},
      :duchy => {
        :type => :victory,
        :cost => 5},
      :provence => {
        :type => :victory,
        :cost => 8},
      :copper => {
        :type => :treasure,
        :cost => 0},
      :silver => {
        :type => :treasure,
        :cost => 3},
      :gold => {
        :type => :treasure,
        :cost => 6},
      :curse => {
        :type => :victory,
        :cost => 0},
        
      :cellar => {
        :type => :action,
        :cost => 2,
        :actions => 1,
        :description => 'Discard X cards, draw X cards',
        :behaviour => lambda {|player, card|
          player[:actions] += card[:actions]

          discard_count = 0
          while discarded = prompt_player_for_card_in_hand(player, :prompt => "Choose a card to discard", :required => false) 
            discard_count += 1
          end
          discard_count.times { draw_card(player) }
        }},

      :end => {}
     })

    @board = [
      [cards[:copper]] * 60,
      [cards[:silver]] * 40,
      [cards[:gold]] * 30,
      [cards[:estate]] * 8,
      [cards[:duchy]]  * 8,
      [cards[:provence]]  * 8,
      [cards[:curse]] * 30,
      [cards[:cellar]]  * 8
    ]

    @player = {
      :actions => 1,
      :hand    => [],
      :discard => [],
      :played  => [],
      :deck => randomize(
        [cards[:cellar]] * 5 +
        [cards[:estate]] * 3
      )
    #   :deck    => randomize(
    #     [cards[:copper]] * 7 +
    #     [cards[:estate]] * 3
    #   )
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
  
  def run
    painter = Painter.new
    begin
      ctx = painter.draw(self)
      painter.wait_for_input(ctx)
    ensure
      painter.finalize
    end
  end

  class Painter
    include FFI::NCurses

    def initialize
      initscr
      start_color
  
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

    def wait_for_input(ctx)
      wgetch(ctx)
    end

    def finalize
      endwin
    end

    def draw(game)
      curs_set 0
     
      board_frame = newwin(14, 80, 0, 0)
      board = newwin(12, 78, 1, 1)

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
        wattr_set board, A_NORMAL, color_index, nil

        wprintw(board, text.to_s)
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

      header.each do |pile|
        card = pile.first

        print_with_color[:yellow, card[:cost]]
        print_with_color[:red,    type_char[card[:type]]]
        print_with_color[:blue,   pile.size]
        print_with_color[:white,  " %s" % card[:name]]
        print_with_color[:white, ' ']
      end

      print_with_color[:white, "\n"]

      body.each do |pile|
        card = pile.first

        print_with_color[:white, ' ']
        print_with_color[:yellow, card[:cost]]
        print_with_color[:red,    type_char[card[:type]]]
        print_with_color[:blue,   '%-2i' % pile.size]
        print_with_color[:white,  " %-#{max_name_length}s " % card[:name]]

        print_with_color[:cyan_back,    card[:cards] || ' ']
        print_with_color[:green_back,   card[:actions] || ' ']
        print_with_color[:magenta_back, card[:buys] || ' ']
        print_with_color[:yellow_back,  card[:gold] || ' ']

        print_with_color[:white,  " %-#{max_name_length}s\n" % card[:description]]
      end
      wattr_set board_frame, A_NORMAL, 7, nil
      box(board_frame, 0, 0)
      board
    end
  end
end

Game.new.run
