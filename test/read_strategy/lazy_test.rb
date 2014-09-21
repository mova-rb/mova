require "test_helper"

module Mova
  class LazyReadStrategyTest < Minitest::Test
    include Test::Doubles

    def translator_class
      Struct.new(:storage) do
        include ReadStrategy::Lazy
      end
    end

    def translator
      @translator ||= translator_class.new(storage)
    end

    def test_read_first
      expect(storage).to receive(:read).with("de.hello") { "Hallo" }
      assert_equal "Hallo", translator.read_first([:de], ["hello"])
    end

    def test_read_first_returns_nil_when_nothing_found
      expect(storage).to receive(:read).with("de.hello") { nil }
      assert_nil translator.read_first([:de], ["hello"])
    end

    def test_read_first_fallbacks_to_next_scope
      expect(storage).to receive(:read).ordered.with("de.hello") { nil }
      expect(storage).to receive(:read).ordered.with("de.hi") { "Hallo" }
      assert_equal "Hallo", translator.read_first([:de], ["hello", "hi"])
    end

    def test_read_first_fallbacks_when_empty_result_in_storage
      expect(storage).to receive(:read).ordered.with("de.hello") { "" }
      expect(storage).to receive(:read).ordered.with("de.hi") { "Hallo" }
      assert_equal "Hallo", translator.read_first([:de], ["hello", "hi"])
    end

    def test_read_first_fallbacks_to_next_locale
      expect(storage).to receive(:read).ordered.with("de.hello") { nil }
      expect(storage).to receive(:read).ordered.with("de.hi") { nil }
      expect(storage).to receive(:read).ordered.with("en.hello") { "Hello" }
      assert_equal "Hello", translator.read_first([:de, :en], ["hello", "hi"])
    end
  end
end
