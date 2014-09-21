require "test_helper"

module Mova
  class AcceptanceTest < Minitest::Test
    def test_get
      translator = Translator.new.tap do |t|
        def t.locales_to_try(current_locale)
          [current_locale, :en]
        end
      end

      translator.put(en: {global: {hello: "world"}}, de: {hi: "Hallo"})

      assert_equal "Hallo", translator.get(:hi, :de)
      assert_equal "world", translator.get("global.hello", :de)
      assert_equal "", translator.get("global.hello", [:de])
      assert_equal "world", translator.get(["hello", "global.hello"], :en)
      assert_equal "", translator.get(:nothing, :en)
      assert_equal "nothing", translator.get(:nothing, :en, default: "nothing")
    end
  end
end
