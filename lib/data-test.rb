require 'ffi-ncurses'
require File.dirname(__FILE__) + '/ui'

def log(message)
  @log ||= File.open('debug.log', 'a')
  @log.puts message
  @log.flush
end

module Dominion
  module Util
    def generate_names!(cards)
      cards.each do |key, values|
        values[:key]  = key
        values[:name] = key.to_s.gsub(/\b('?[a-z])/) { $1.capitalize }

        existing = values[:behaviour]
        values[:behaviour] = lambda do |player, card|
          player[:actions] += card[:actions].to_i
          player[:buys]    += card[:buys].to_i
          card[:cards].to_i.times do
            draw_card(player)
          end
          existing[player, card] if existing
        end
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

      player[:hand] << player[:deck].shift unless player[:deck].empty?
    end

    def buy_card(board, player, card_name)
      pile = board.detect {|pile| pile[0][:name] == card_name.to_s }
      player[:discard] << pile.shift
      player[:buys] -= 1
    end

    def play_card(player, card_name)
      card = player[:hand].detect {|x| x[:name] == card_name.to_s } 

      player[:hand].delete_at(player[:hand].index(card))
      player[:played] << card
      player[:actions] -= 1

      card[:behaviour][player, card]
    end

    def cleanup(board, player)
      player[:discard] += player[:hand]
      player[:discard] += player[:played]
      player[:hand] = []
      player[:played] = []
      5.times { draw_card(player) }
      player[:actions] = 1
      player[:buys]    = 1
      player[:gold]    = 0
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

  attr_accessor :board, :cards, :player, :turn

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
        :gold => 1,
        :cost => 0},
      :silver => {
        :type => :treasure,
        :gold => 2,
        :cost => 3},
      :gold => {
        :type => :treasure,
        :gold => 3,
        :cost => 6},
      :curse => {
        :type => :victory,
        :cost => 0},
        
      :chapel => {
        :type => :action,
        :cost => 2,
        :description => 'Trash <= 4 cards'},
      :village => {
        :type => :action,
        :cost => 3,
        :actions => 2,
        :cards => 1},
      :market => {
        :type => :action,
        :cost => 5,
        :actions => 1,
        :cards => 1,
        :gold => 1,
        :buys => 1},
      :cellar => {
        :type => :action,
        :cost => 2,
        :actions => 1,
        :description => 'Discard X cards, draw X cards',
        :behaviour => lambda {|player, card|

          discard_count = 0
          #while discarded = prompt_player_for_card_in_hand(player, :prompt => "Choose a card to discard", :required => false) 
          #  discard_count += 1
          #end
          #discard_count.times { draw_card(player) }
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
      [cards[:chapel]]  * 8,
      [cards[:cellar]]  * 8,
      [cards[:village]]  * 8,
      [cards[:market]]  * 8
    ]

    @player = {
      :actions => 1,
      :buys => 1,
      :gold => 0,
      :hand    => [],
      :discard => [],
      :played  => [],
      :deck => randomize(
        [cards[:village]] + 
        [cards[:cellar]] * 3 +
        [cards[:copper]] * 3 +
        [cards[:estate]] * 3
      )
    #   :deck    => randomize(
    #     [cards[:copper]] * 7 +
    #     [cards[:estate]] * 3
    #   )
    }

    @turn = 1
    cleanup(board, @player)
  end

  def treasure(player)
    player[:gold] + player[:hand].select {|x| 
      x[:type] == :treasure 
    }.map {|x|
      raise x.inspect unless x[:gold]
      x[:gold] 
    }.inject {|a, b| 
      a + b 
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
    running = true
    engine = Dominion::UI::NCurses.new

    while running
      skip = false
      if player[:actions] > 0
        engine.card_active = lambda {|card| card[:type] == :action && player[:hand].include?(card)}
        engine.prompt = {
          :prompt => "action (#{player[:actions]} left)?",
          :autocomplete => lambda {|input|
            suggest = input.length == 0 ? nil : player[:hand].detect {|x|
              x[:type] == :action && x[:name] =~ /^#{input}/i
            }
            suggest ? suggest[:name] : nil
          },
          :accept => lambda {|input|
            if input
              play_card(player, input)
            else
              player[:actions] = 0
            end
            engine.prompt = nil
          }
        }
      elsif player[:buys] > 0
        engine.card_active = lambda {|card| 
          card[:cost] <= treasure(player)
        }
        engine.prompt = {
          :prompt => "buy (#{player[:buys]} left)?",
          :autocomplete => lambda {|input|
            suggest = input.length == 0 ? nil : board.map(&:first).detect {|x|
              x[:cost] <= treasure(player) && x[:name] =~ /^#{input}/i
            }
            suggest ? suggest[:name] : nil
          },
          :accept => lambda {|input|
            if input
              buy_card(board, player, input)
            else
              player[:buys] = 0
            end
            engine.prompt = nil
          }
        }
      else
        # Run the cleanup phase
        cleanup(board, player)
        skip = true
        @turn += 1
      end

      unless skip
        ctx = engine.draw(self)
        engine.step(ctx)
      end
    end
  ensure
    engine.finalize if engine
  end

end

Game.new.run
