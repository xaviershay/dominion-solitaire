#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#

class Card < Struct.new(:name, :buys, :actions, :cards, :gold, :extra)
end

cards = [
  Card.new("Smithy", 0, 0, 3, 0, ""),
  Card.new("Cellar", 0, 1, 0, 0, "Discard X cards, +X cards"),
  Card.new("Chapel", 0, 0, 0, 0, "Trash <= 4 cards"),
  Card.new("Workshop", 0, 0, 0, 0, "Gain a card <= 4"),
  Card.new("Chancellor", 0, 0, 0, 2, "You may put your deck into your discard"),
  Card.new("Council Room", 1, 0, 4, 0, "Each other player draws a card"),
  Card.new("Mine", 0,0,0, 0, "Trash a T, gain a T costing <= 3 more to your hand"),
  Card.new("Cellar", 0, 1, 0, 0, "Discard X cards, +X cards"),
  Card.new("Chapel", 0, 0, 0, 0, "Trash <= 4 cards"),
  Card.new("Workshop", 0, 0, 0, 0, "Gain a card <= 4")
]

require 'rubygems'
require 'ffi-ncurses'
include FFI::NCurses

initscr
begin
  # turn cursor off
   curs_set 0
# 
   board = newwin(14, 80, 0, 0)

#   initscr
#   curs_set 0
  #win = newwin(6, 12, 15, 15)
#   win = newwin(1, 12, 15, 15)
#   box(win, 0, 0)
#   inner_win = newwin(4, 10, 16, 16)
#   waddstr(inner_win, (["Hello window!"] * 5).join(' '))
#   wrefresh(win)
#   wrefresh(inner_win)
#   ch = wgetch(inner_win)
#   raise

  # initialize colour
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
#   
#   0.upto(15) do |i|
#     attr_set A_NORMAL, i, nil
#     waddch(board, ?A + i)
#   end
#   waddstr board, "\n"
# 
# 
  print_attr = lambda do |i|
    i == 0 ?
      wprintw(board, ' ') :
      wprintw(board, "%i", :int, i)
  end
  wprintw(board, "\n")
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "0")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "T")
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Copper')
  wattr_set board, A_NORMAL, 7, nil

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "3")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "T")
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Silver')

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "6")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "T")
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Gold')

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "2")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "V")
  wattr_set board, A_NORMAL, 4, nil
  wprintw(board, "%i", :int, 8)
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Estate')

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "5")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "V")
  wattr_set board, A_NORMAL, 4, nil
  wprintw(board, "%i", :int, 8)
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Dutchy')

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "8")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "V")
  wattr_set board, A_NORMAL, 4, nil
  wprintw(board, "%i", :int, 8)
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Provence')

  wprintw(board, " ")
  wattr_set board, A_NORMAL, 3, nil
  wprintw(board, "0")
  wattr_set board, A_NORMAL, 1, nil
  wprintw(board, "V")
  wattr_set board, A_NORMAL, 4, nil
  wprintw(board, "%i", :int, 8)
  wattr_set board, A_NORMAL, 7, nil
  wprintw(board, " %s", :string, 'Curse')

  wprintw(board, "\n")
  wprintw(board, "\n")

  cards.each do |card|
    wattr_set board, A_NORMAL, 7, nil
    wprintw(board, " ")
    wattr_set board, A_NORMAL, 3, nil
    wprintw(board, "2")
    wattr_set board, A_NORMAL, 1, nil
    wprintw(board, "A")
    wattr_set board, A_NORMAL, 4, nil
    wprintw(board, "%i ", :int, 8)
    wattr_set board, A_NORMAL, 7, nil
    wprintw(board, "%-15s", :string, card.name)
    wattr_set board, A_NORMAL, 14, nil
    print_attr[card.cards]
    wattr_set board, A_NORMAL, 10, nil
    print_attr[card.actions]
    wattr_set board, A_NORMAL, 13, nil
    print_attr[card.buys]
    wattr_set board, A_NORMAL, 11, nil
    print_attr[card.gold]
    wattr_set board, A_NORMAL, 0, nil
    wprintw(board," %s", :string, card.extra)
    wprintw(board, "\n")
  end
#   waddstr board, " "
#   0.upto(15) do |i|
#     wattr_set board, A_NORMAL, i, nil
#     waddch(board, ?A + i)
#   end
#   waddstr board, "\n"
    wattr_set board, A_NORMAL, 7, nil
 box(board, 0, 0)
# 
#   0.upto(15) do |i|
#     attr_set A_NORMAL, i, nil
#     addch(?A + i)
#   end
  
  # add character and attribute together
#  addch(?Z | COLOR_PAIR(1)) # red

  
#   waddstr board, "Press any key"

  # display and pause for key press
  wrefresh(board)
  ch = wgetch(board)
ensure
  endwin
  puts can_change_color
end

