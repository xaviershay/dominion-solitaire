module Dominion
  module Util
    def generate_names!(cards)
      cards.each do |key, values|
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

      card[:behaviour][player]
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
      :copper => {
        :type => :treasure,
        :cost => 0},
      :silver => {
        :type => :treasure,
        :cost => 3},
        
      :cellar => {
        :type => :action,
        :cost => 2,
        :behaviour => lambda {|player|
          player[:actions] += 1

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
      [cards[:estate]] * 8,
      [cards[:duchy]]  * 8
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
end

Game.new.test
