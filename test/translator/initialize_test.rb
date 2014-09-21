require "test_helper"

module Mova
  class TranslatorInitializeTest < Minitest::Test
    include Test::Doubles

    def translator
      @translator ||= Translator.new
    end

    def test_assigns_storage
      translator = Translator.new(storage: storage)
      assert_equal storage, translator.storage
    end

    def test_assigns_default_storage
      assert_respond_to translator.storage, :read
      assert_respond_to translator.storage, :read_multi
      assert_respond_to translator.storage, :write
      assert_respond_to translator.storage, :exist?
    end
  end
end
