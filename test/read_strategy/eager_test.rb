require "test_helper"
require "mova/read_strategy/eager"

module Mova
  class EagerReadStrategyTest < Minitest::Test
    include Test::Doubles

    def translator_class
      Struct.new(:storage) do
        include ReadStrategy::Eager
      end
    end

    def translator
      @translator ||= translator_class.new(storage)
    end

    def test_read_first
      expect(storage).to receive(:read_multi).with("de.hello").and_return("de.hello" => "Hallo")
      assert_equal "Hallo", translator.read_first([:de], ["hello"])
    end

    def test_read_first_returns_nil_when_nothing_found
      expect(storage).to receive(:read_multi).with("de.hello").and_return({})
      assert_nil translator.read_first([:de], ["hello"])
    end

    def test_read_first_fallbacks_to_next_scope
      expect(storage).to receive(:read_multi).with("de.hello", "de.hi").and_return("de.hi" => "Hallo")
      assert_equal "Hallo", translator.read_first([:de], ["hello", "hi"])
    end

    def test_read_first_fallbacks_when_empty_result_in_storage
      expect(storage).to receive(:read_multi).with("de.hello", "de.hi").and_return(
        "de.hello" => "", "de.hi" => "Hallo"
      )
      assert_equal "Hallo", translator.read_first([:de], ["hello", "hi"])
    end

    def test_read_first_fallbacks_to_next_locale
      expect(storage).to receive(:read_multi).with("de.hello", "de.hi", "en.hello", "en.hi").and_return(
        "en.hello" => "Hello", "en.hi" => "hi"
      )
      assert_equal "Hello", translator.read_first([:de, :en], ["hello", "hi"])
    end
  end
end
