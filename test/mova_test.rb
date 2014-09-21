require "test_helper"

module Mova
  class MovaTest < Minitest::Test
    def test_presence_nil
      assert_nil Mova.presence(nil)
    end

    def test_presence_empty
      assert_nil Mova.presence("")
    end

    def test_presence_non_empty
      assert_equal "hello", Mova.presence("hello")
    end

    def test_presence_spaces_only
      assert_equal "  ", Mova.presence("  ")
    end
  end
end
