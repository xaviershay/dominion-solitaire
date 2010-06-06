require 'spec'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'dominion/game'

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
    prompt = @game.engine.prompt

    prompt[:accept][prompt[:autocomplete][key]] if prompt
  end

  def playing_card(card)
    card[:behaviour][@game, subject]
    yield if block_given?
    input ''
  end

  def deck(cards = nil)
    @game.player[:deck] = cards || @game.player[:deck]
  end

  def hand(cards = nil)
    @game.player[:hand] = cards || @game.player[:hand]
  end

  def trash(cards = nil)
    @game.player[:trash] = cards || @game.player[:trash]
  end
end


Spec::Runner.configure do |config|
  config.include CardMacros
end

def describe_card(key, &block)
  describe(key.to_s) do
    subject { card(key) }

    before do
      game_with_cards(key)
    end

    instance_eval(&block)
  end
end