require 'spec'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'dominion/game'
require File.expand_path(File.dirname(__FILE__) + '/cards/common/action_spec')
require File.expand_path(File.dirname(__FILE__) + '/cards/common/attack_spec')

class Proc
  def inspect
    "[PROC]"
  end
end

Spec::Matchers.define :have_prompt_with_autocomplete do |autocomplete_strategy|
  match do |game|
    case autocomplete_strategy
    when :cards_in_hand then
      # TODO: Make this match the :actions_in_hand one
      game.prompt
      begin
        old_player = game.player.dup

        game.player[:deck] = [game.card(:estate)]
        game.player[:hand] = [game.card(:copper)]
        game.prompt[:autocomplete]['co'].should == 'Copper'
        game.prompt[:autocomplete]['es'].should == nil
        game.prompt[:autocomplete]['ce'].should == nil
      ensure
        game.player = old_player
      end

    when :actions_in_hand then
      to_match = game.player[:hand].select {|x| [*x[:type]].include?(:action) }
      to_not_match = game.player[:hand] - to_match

      to_match.each do |card|
        game.prompt[:autocomplete][card[:name][0..2]].should == card[:name]
        game.card_active[card].should == true
      end

      to_not_match.each do |card|
        game.prompt[:autocomplete][card[:name][0..2]].should == nil
        game.card_active[card].should == false
      end
    end
  end

  failure_message_for_should do |game|
    "expected a prompt with autocomplete strategy :#{autocomplete_strategy}"
  end
end

Spec::Matchers.define :have_prompt do
  match do |game|
    game.prompt
  end

  failure_message_for_should do |game|
    "expected a prompt"
  end
end

Spec::Matchers.define :have_cards do |cards|
  match do |pile|
    keys(pile) == keys(cards)
  end

  failure_message_for_should do |pile|
    "expected #{keys(pile).inspect} to be #{keys(cards).inspect}"
  end

  def keys(pile)
    pile.map {|x| x[:key] }.sort_by(&:to_s)
  end
end

Spec::Matchers.define :have_stack do |card, number|
  match do |board|
    stack = board.detect {|x| x[0][:key] == card }
    if number
      stack && stack.length == number
    else
      stack
    end
  end

  failure_message_for_should do |board|
    "expected board #{format_board(board)} to have #{number} x #{card}"
  end

  failure_message_for_should_not do |board|
    "expected board #{format_board(board)} to not have #{card}"
  end

  def format_board(board)
    "|%s|" % board.map {|x| "%i x %s" % [x.length, x[0][:name]] }.join(", ")
  end
end

module CardMacros
  def game_with_cards(*cards)
    @game = Dominion::Game.new.tap do |game|
      game.load_cards(*cards + [:copper, :estate])
      game.engine = Dominion::Engine.new
    end
  end

  def game
    @game
  end

  def card(key)
    subject unless @game
    @game.card(key)
  end

  def cards(key, n)
    [card(key)] * n
  end

  def input(key)
    prompt = @game.prompt

    prompt[:accept][prompt[:autocomplete][key]] if prompt
  end

  def playing_card(card = nil)
    card ||= subject
    player[:played] << card
    card[:behaviour][@game, subject]
    yield if block_given?
    input ''
  end

  def player
    @game.player
  end

  def deck(cards = nil)
    player[:deck] = cards || player[:deck]
  end

  def hand(cards = nil)
    player[:hand] = cards || player[:hand]
  end

  def trash(cards = nil)
    player[:trash] = cards || player[:trash]
  end

  def discard(cards = nil)
    player[:discard] = cards || player[:discard]
  end

  def played(cards = nil)
    player[:played] = cards || player[:played]
  end
end


Spec::Runner.configure do |config|
  config.include CardMacros
end

def describe_card(key, opts = {}, &block)
  describe(key.to_s) do
    subject { card(key) }

    before do
      game_with_cards(*[key] + (opts[:needs_cards] || []))
    end

    instance_eval(&block)
  end
end

def log(*args)
end
