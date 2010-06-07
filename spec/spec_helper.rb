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
    game.engine.prompt
      # TODO: Check auto complete
    begin
      old_player = game.player.dup

      game.player[:deck] = [game.card(:estate)]
      game.player[:hand] = [game.card(:copper)]
      game.engine.prompt[:autocomplete]['co'].should == 'Copper'
      game.engine.prompt[:autocomplete]['es'].should == nil
      game.engine.prompt[:autocomplete]['ce'].should == nil
    ensure
      game.player = old_player
    end
  end

  failure_message_for_should do |game|
    "expected a prompt with autocomplete strategy :#{autocomplete_strategy}"
  end
end

Spec::Matchers.define :have_prompt do
  match do |game|
    game.engine.prompt
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

module CardMacros
  def game_with_cards(*cards)
    @game = Dominion::Game.new.tap do |game|
      game.load_cards(*cards + [:copper, :estate])
    end
  end

  def game
    @game
  end

  def card(key)
    @game.card(key)
  end

  def cards(key, n)
    [card(key)] * n
  end

  def input(key)
    prompt = @game.engine.prompt

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
