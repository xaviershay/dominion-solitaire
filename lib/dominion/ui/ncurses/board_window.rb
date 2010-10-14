module Dominion; module UI; end; end;
class Dominion::UI::NCurses < Dominion::Engine
  class BoardWindow < Window
    def initialize(*args)
      super
    end

    def coords
      [14, 80, 0, 0]
    end

    def title
      'Board'
    end

    def draw
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

        print( :white, ' ' ) if i > 0
        print( :yellow, card[:cost] )
        print( :red,    type_char.detect {|x| [*card[:type]].include?(x[0]) }[1] )
        print( :blue,   pile.size )
        print( :white,  " %s" % card[:name] )
      end
      print( :white, "\n" ) 
      body.sort_by {|x| [x[0][:cost], x[0][:name]] }.each do |pile|
        card = pile.first

        print( :white, ' ' )
        print( :yellow, card[:cost] )
        print( :red,    type_char.detect {|x| [*card[:type]].include?(x[0]) }[1] )
        print( :blue,   '%-2i' % pile.size )
        if game.card_active?(card)
          print( :white,  " %-#{max_name_length}s " % card[:name], true )
        else
          print( :white,  " %-#{max_name_length}s " % card[:name] )
        end

        print( :cyan_back,    card[:cards]   || ' ' )
        print( :green_back,   card[:actions] || ' ' )
        print( :magenta_back, card[:buys]    || ' ' )
        print( :yellow_back,  card[:gold]    || ' ' )

        print( :white,  " %-#{max_name_length}s\n" % card[:description] )
      end
    end
  end
end
