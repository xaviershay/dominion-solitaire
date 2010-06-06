require 'spec'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'dominion/game'

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
    @game = Game.new.tap do |game|
      game.load_cards(*cards)
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
    @game.engine.prompt[:accept][key]
  end

  def playing_card(card)
    card[:behaviour][@game, subject]
    yield if block_given?
    input nil
  end

  def deck(cards = nil)
    @game.player[:deck] = cards || @game.player[:deck]
  end

  def hand(cards = nil)
    @game.player[:hand] = cards || @game.player[:hand]
  end
end


Spec::Runner.configure do |config|
  config.include CardMacros
end
