require "test_helper"

module Mova
  class TranslatorGetTest < Minitest::Test
    def translator
      @translator ||= Translator.new
    end

    def test_get
      expect(translator).to receive(:locales_to_try).with(:en).and_return([:en])
      expect(translator).to receive(:keys_to_try).with(:hello).and_return([:hello])
      expect(translator).to receive(:read_first).with([:en], [:hello]).and_return("Hello")
      assert_equal "Hello", translator.get(:hello, :en)
    end

    def test_get_allows_to_override_locales_to_try
      expect(translator).to receive(:keys_to_try).with(:hello).and_return([:hello])
      expect(translator).to receive(:read_first).with([:de, :en], [:hello]).and_return("Hello")
      assert_equal "Hello", translator.get(:hello, [:de, :en])
    end

    def test_get_allows_to_override_keys_to_try
      expect(translator).to receive(:locales_to_try).with(:en).and_return([:en])
      expect(translator).to receive(:read_first).with([:en], [:hi, :hello]).and_return("Hello")
      assert_equal "Hello", translator.get([:hi, :hello], :en)
    end

    def test_get_uses_default_when_read_first_returns_nil
      expect(translator).to receive(:read_first).and_return(nil)
      expect(translator).to receive(:default).and_return("hi")
      assert_equal "hi", translator.get(:hello, :en)
    end

    def test_get_passes_to_default_locales_keys_and_its_options
      expect(translator).to receive(:locales_to_try).with(:en).and_return([:en])
      expect(translator).to receive(:keys_to_try).with(:hello).and_return([:hello])
      expect(translator).to receive(:read_first).with([:en], [:hello]).and_return(nil)
      expect(translator).to receive(:default).with([:en], [:hello], my: "option")
      translator.get(:hello, :en, my: "option")
    end

    def test_get_passes_its_options_to_default
      expect(translator).to receive(:read_first).and_return(nil)
      expect(translator).to receive(:default).with(instance_of(Array), instance_of(Array), {my: "option"}).and_return("hi")
      assert_equal "hi", translator.get(:hello, :en, my: "option")
    end

    def test_get_uses_option_default_first
      expect(translator).to receive(:locales_to_try).with(:en).and_return([:en])
      expect(translator).to receive(:keys_to_try).with(:hello).and_return([:hello])
      expect(translator).to receive(:read_first).with([:en], [:hello]).and_return(nil)
      assert_equal "hi", translator.get(:hello, :en, default: "hi")
    end
  end
end
