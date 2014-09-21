require "test_helper"

module Mova
  class TranslatorPutTest < Minitest::Test
    include Test::Doubles

    def translator
      @translator ||= Translator.new(storage: storage)
    end

    def test_put_writes_key_if_it_doesnt_exist
      expect(storage).to receive(:exist?).with("en.hello").and_return(false)
      expect(storage).to receive(:write).with("en.hello", "world")
      translator.put(en: {hello: "world"})
    end

    def test_put_doesnt_write_key_if_it_exists
      expect(storage).to receive(:exist?).with("en.hello").and_return(true)
      translator.put(en: {hello: "world"})
    end

    def test_put_bang_writes_key_if_it_exists
      expect(storage).to receive(:write).with("en.hello", "world")
      translator.put!(en: {hello: "world"})
    end
  end
end
